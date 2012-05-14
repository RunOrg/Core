(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

let details_url ctx input prefix id = 
  UrlR.build (ctx # instance) (input # segments) (prefix, `Item (IItem.decay id))

let list_url ctx input prefix = 
  UrlR.build (ctx # instance) (input # segments) (prefix, `List)

(* Extracting a list of images from the album ---------------------------------------------- *)

let fetch_list ?start ~(ctx:'any CContext.full) ~album ~details input more () = 

  let i18n     = ctx # i18n in 
  let self_opt = ctx # self_if_exists in 
  let cuid     = ctx # cuid in 
  let alid     = MAlbum.Get.id album in
  let instance = ctx # instance in 

  let! admin_opt = ohm (MAlbum.Can.admin album) in

  let! items, last = ohm (MItem.list ?self:self_opt (`album alid) ~count:9 start) in

  let render item = 

    let! image_payload = req_or (return None) begin match item # payload with 
      | `Image    i -> Some i
      | `Message  _
      | `MiniPoll _
      | `Chat     _ 
      | `ChatReq  _ 
      | `Doc      _ -> None
    end in 

    let! aid = ohm (MAvatar.details (image_payload # author)) in
   
    let by = CName.get i18n aid in
    let by_url = UrlProfile.page ctx (image_payload # author) in

    let file = image_payload # file in

    let! thumbnail = ohm (CImage.small (Some file)) in   

    let url = details (item # id) in

    let liid = IItem.Deduce.read_can_like (item # id) in

    let! liked = ohm (
      match self_opt with None -> return false | Some self ->
	CItem.liked self item 
    ) in

    let remove = match item # own with 
	
      (* We own the item, so we can remove it. *)
      | Some own -> let rmiid = IItem.Deduce.own_can_remove own in 
		    Some ((UrlWall.remove ()) # build instance cuid rmiid)

      | None -> match admin_opt with 
	  
	  (* We own the feed, so we can remove the item. *)
	  | Some album -> Some (UrlAlbum.moderate # build instance
				  (MAlbum.Get.id album) (IItem.decay (item # id)))
	    
	  (* We own neither item nor feed, so no removal! *)
	  | None -> None
    in

    let item = object 
      method by       = by
      method by_url   = by_url
      method picture  = thumbnail
      method url      = url
      method time     = item # time
      method liked    = liked
      method likes    = item # nlike
      method comments = item # ncomm
      method like     = (UrlWall.like_item ()) # build instance cuid liid
      method remove   = remove
    end in

    return $ Some item
  in

  let next = match last with 
    | None -> None
    | Some float -> 
      let args =  ["start",Json_type.Build.string (string_of_float float)] in
      Some 
	(JsBase.to_event
	   (Js.More.fetch ~args
	      (input # reaction_url more)))
  in 
  
  let! items = ohm (Run.list_filter render items) in

  return (items, next)

(* Displaying more items ------------------------------------------------------------------ *)
  
let more_reaction ~ctx ~album = 
  O.Box.reaction "album-more" begin fun self input (prefix,_) response ->
  
    let details = details_url ctx input prefix in
    
    let i18n = ctx # i18n in 
    let fail = return (Action.json (Js.More.return identity) response) in
    
    let start_opt = 
      try match input # post "start" with
	| None -> None
	| Some str -> Some (float_of_string str)
      with _ -> None
    in
    
    let! start = req_or fail start_opt in
    
    (* Extracting the read-album and the album contents. *)
    let! read_album = ohm_req_or fail (MAlbum.Can.read album) in
    
    let! (list, more) = ohm 
      (fetch_list ~start ~ctx ~album:read_album ~details input self ()) in
    
    return (Action.json (Js.More.return (VAlbum.more ~more ~list ~i18n)) response)
  end

(* Upload action --------------------------------------------------------------------------- *)

module Upload = struct

  let reaction ~ctx ~album =
    O.Box.reaction "upload" begin fun self input url response ->
     
      let i18n = ctx # i18n in
      
      let inst = MAlbum.Get.write_instance album |> IInstance.Deduce.can_see_usage in
      
      let! (used, total) = ohm (MFile.Usage.instance inst) in
      
      let available = total -. used in 
      
      let title = I18n.translate i18n (`label "album.upload") in    
      let body = 
	let prepare = (UrlFile.Client.put_img ()) # build
	  (ctx # instance) (MAlbum.Get.id album)
	in      
	VAlbum.upload ~prepare ~available ~total ~i18n
      in
      
      return (Action.javascript (Js.Dialog.create body title) response)
    end

end

(* The list box ---------------------------------------------------------------------------- *)

let list_box ~ctx ~(album:'a MAlbum.t) ~write_album_opt = 
  
  let! more_reaction = more_reaction ~ctx ~album in
  
  let! upload_reaction_opt = (
    match write_album_opt with 
      | Some album -> (fun f -> Upload.reaction ~ctx ~album (fun n -> f (Some n)))
      | None       -> (fun f -> f None)
  ) in
  
  O.Box.leaf 
    begin fun input (prefix,_) ->
      
      let i18n = ctx # i18n in 
     
      let details = details_url ctx input prefix in
 
      let actions =
	BatOption.map (fun reaction ->
	  Js.runFromServer (input # reaction_url reaction)
	) upload_reaction_opt 
      in
      
      (* Extracting the read-album and the album contents. *)
      let! read_album_opt = ohm (MAlbum.Can.read album) in
      
      let forbidden = return (VAlbum.forbidden ~i18n) in
      
      let! read_album = req_or forbidden read_album_opt in
      
      let! (list, more) = ohm
	(fetch_list ~ctx ~album:read_album ~details input more_reaction ()) in
      
      return (VAlbum.page ~actions ~more ~list ~i18n)
    end
  

(* CItem details box ----------------------------------------------------------------------- *)

let item_box ~ctx ~album ~item = 
  O.Box.leaf begin fun bctx (prefix,_) ->

    let back = list_url ctx bctx prefix in
    let details = details_url ctx bctx prefix in

    let result render url prev next = 
      return (VAlbum.ShowItem.render (object
	method contents = render
	method back     = back
	method url      = url 
	method prev     = BatOption.map details prev
	method next     = BatOption.map details next
      end) (ctx # i18n))
    in
    
    let missing = result (VAlbum.Missing.render () (ctx # i18n)) None None None in

    let! admin_album_opt = ohm (MAlbum.Can.admin album) in
    let from =
      BatOption.map
	(fun album -> `album (MAlbum.Get.id album))
	admin_album_opt
    in
    
    let! item = ohm_req_or missing (MItem.try_get ctx item) in

    let! (prev,next) = ohm (MItem.prev_next item) in

    let image_opt = match item # payload with 
      | `Image    i -> Some (i # file)
      | `Message  _
      | `MiniPoll _
      | `Chat     _ 
      | `ChatReq  _ 
      | `Doc      _ -> None
    in

    let! url = ohm (CImage.large image_opt) in

    let config = object
      method react  = true
      method chat _ = None
    end in 

    let! render = ohm (CItem.display ~ctx ~from ~config ~item) in
    result render (Some url) prev next

  end

(* The box itself -------------------------------------------------------------------------- *)

let box ~ctx ~album =

  O.Box.decide 
    begin fun _ (_,what) ->
      match what with 
	| `List -> 
      
	  let! write_album_opt = ohm (MAlbum.Can.write album) in
	  return (list_box ~ctx ~album ~write_album_opt)

	| `Item item ->
	  return (item_box ~ctx ~album ~item)
    end
  |> O.Box.parse CSegs.item_or_list

(* Moderating an image *)

module Moderate = struct

  let () = CClient.User.register CClient.is_contact UrlAlbum.moderate 
    begin fun ctx request response ->
      
      let fail = return (Action.javascript Js.panic response) in

      let! aid = req_or fail (request # args 0) in
      let! album = ohm_req_or fail (MAlbum.try_get ctx (IAlbum.of_string aid)) in

      let! item = req_or fail (request # args 1) in
      let item = IItem.of_string item in 

      let! album = ohm_req_or fail (MAlbum.Can.admin album) in
     
      let! () = ohm (MItem.Remove.moderate item (`album (MAlbum.Get.id album))) in
      return (Action.javascript (Js.removeParent ".album-item") response)

    end
end
