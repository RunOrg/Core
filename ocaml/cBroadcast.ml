(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module PostFmt = Fmt.Make(struct
  type json t = <
    title : string ;
    body  : string
  >
end)

let post_reaction ~ctx callback = 
  
  let iid_opt = BatOption.map IIsIn.instance (IIsIn.Deduce.is_admin (ctx # myself)) in 
  
  match iid_opt with None -> callback None | Some iid -> 

    let! reaction = O.Box.reaction "post" begin fun _ bctx _ response -> 

      let! post = req_or (return response) $ PostFmt.of_json_safe (bctx # json) in

      let! pic  = ohm $ ctx # picture_small (ctx # instance # pic) in
      let! self = ohm $ ctx # self in

      let! bid  = ohm $ MBroadcast.post iid self (`Post post) in

      let post = object
	method key     = ctx # instance # key
	method name    = ctx # instance # name
	method title   = post # title
	method text    = post # body 
	method time    = Unix.gettimeofday () -. 5.0 
	method forward = false
	method pic     = pic
	method can_del = true
	method can_fwd = false
	method id      = bid
	method rss     = None
	method url     = UrlBroadcast.link # build bid
      end in 

      return $ O.Action.json 
	(Js.Html.return (VBroadcast.ProfileListItem.render post (ctx # i18n)))
	response

    end in
    
    callback (Some reaction)

let delete_reaction ~ctx callback = 
  
  let iid_opt = BatOption.map IIsIn.instance (IIsIn.Deduce.is_admin (ctx # myself)) in 
  
  match iid_opt with None -> callback None | Some iid -> 

    let! reaction = O.Box.reaction "delete" begin fun _ bctx _ response -> 

      let finish = return $ O.Action.json [] response in

      let! self = ohm $ ctx # self in
      let! bid  = req_or finish $ IBroadcast.of_json_safe (bctx # json) in
      
      let! () = ohm $ MBroadcast.remove iid self bid in 

      finish
      
    end in
    
    callback (Some reaction)

let render_broadcast_list ?post ?delete ~iid ~i18n what = 

  let! list = ohm begin 
    match what with 
      | `List -> MBroadcast.current iid ~count:5 
      | `Broadcast bid -> let! item = ohm $ MBroadcast.get bid in 
			  match item with 
			    | Some item -> return [item] 
			    | None      -> MBroadcast.current iid ~count:5 
  end in 
  
  let render post = 
    let! profile = ohm_req_or (return None) $ MInstance.Profile.get (post # from) in
    let! pic      = ohm $ CPicture.small (profile # pic) in
    
    let title, body, rss = match post # content with 
      | `Post c -> c # title, VText.format (c # body), None
      | `RSS  c -> c # title, OhmSanitizeHtml.html (c # body), Some (c # link) 
    in
    
    return $ Some (object
      method key     = profile # key
      method name    = profile # name
      method title   = title
      method text    = body
      method time    = post # time
      method forward = post # forward <> None
      method pic     = pic
      method id      = post # id
      method can_del = delete <> None
      method can_fwd = false
      method rss     = rss
      method url     = UrlBroadcast.link # build (post # id) 
    end)
  in
  
  let! rendered = ohm $ Run.list_filter render list in 

  let feed = object
    method list   = rendered
    method delete = delete
    method post   = post 
  end in
  
  return $ VBroadcast.ProfileList.render feed i18n     
    
let unbound_box i18n cuid iid = 
  O.Box.leaf begin fun bctx (_,what) -> 
    render_broadcast_list ~iid ~i18n what
  end
  |> O.Box.parse UrlSegs.broadcast_or_list 

let box ~(ctx:'any CContext.full) = 

  let! post = post_reaction ~ctx in 
  let! delete = delete_reaction ~ctx in

  O.Box.leaf begin fun bctx (_,what) -> 

    let  iid  = IInstance.decay (IIsIn.instance (ctx # myself)) in
    let  i18n = ctx # i18n in 

    let delete = BatOption.map (fun delete -> bctx # reaction_url delete) delete in
    let post   = BatOption.map (fun post -> bctx # reaction_url post) post in

    render_broadcast_list ?post ?delete ~iid ~i18n what

  end
  |> O.Box.parse UrlSegs.broadcast_or_list 

(* Redirect to appropriate broadcast. *)

let () = CCore.register UrlBroadcast.link begin fun i18n request response ->

  let  uid_opt   = BatOption.bind 
    CSession.unverified_user_id (request # cookie CSession.name)
  in 

  let fail = 
    let url = 
      if uid_opt = None then UrlNetwork.explore # build [] else 
	UrlMe.build O.Box.Seg.(root ++ CSegs.me_pages) ( (), `News )
    in
    return $ O.Action.redirect url response
  in

  let! bid       = req_or fail (request # args 0) in
  let  bid       = IBroadcast.of_string bid in 
  let! broadcast = ohm_req_or fail $ MBroadcast.get bid in

  let! url = ohm_req_or fail begin 
    if uid_opt = None then 
      return $ Some (UrlNetwork.profile # build_bid (broadcast # from) bid)
    else      
      let! instance_opt = ohm $ MInstance.get (broadcast # from) in
      match instance_opt with 
	| Some instance -> return $ Some 
	  (UrlR.build instance
	     O.Box.Seg.(UrlSegs.(root ++ root_pages ++ home_pages ++ broadcast_or_list))
	     ((((),`Home),`Profile),`Broadcast bid))
	| None -> let! profile = ohm_req_or (return None) $
		    MInstance.Profile.get (broadcast # from) in
		  return $ Some 
		    (UrlMe.build 
		       O.Box.Seg.(UrlSegs.(root ++ me_pages ++ me_network_tabs `Profile ++ 
					      instance_id ++ broadcast_or_list))
		       (((((),`Network),`Profile),Some (broadcast # from)), `Broadcast bid))
  end in 
	   		      
  return $ O.Action.redirect url response

end

