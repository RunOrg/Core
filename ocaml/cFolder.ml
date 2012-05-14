(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

(* Rendering a single item ----------------------------------------------------------------- *)

let render ctx details (item:MItem.item) = 
  
  let! author = req_or (return None) $ MItem.author (item # payload) in
  let! avatar = ohm $ MAvatar.details author in  
  let  by     = CName.get (ctx # i18n) avatar in
  let  by_url = UrlProfile.page ctx author in
  
  let! doc = req_or (return None) begin match item # payload with 
      | `Doc      d -> Some d
      | `Image    _
      | `MiniPoll _
      | `Chat     _ 
      | `ChatReq  _
      | `Message  _ -> None
  end in
  
  let! download = ohm_req_or (return None)
    (MFile.Url.get (doc # file) `File) in

  let item = object 
    method by       = by
    method by_url   = by_url
    method download = download
    method details  = details (item # id)
    method time     = item # time
    method likes    = item # nlike
    method comments = item # ncomm 
    method title    = doc # title
    method ext      = doc # ext
    method size     = doc # size
  end in
  
  return (Some item) 
    
(* Extracting a list of files from the folder ---------------------------------------------- *)

let fetch_list ?start ~(ctx:'any CContext.full) ~folder ~details input more () = 

  let fid      = MFolder.Get.id folder in
  let self_opt = ctx # self_if_exists in

  let! items, last = ohm (MItem.list ?self:self_opt (`folder fid) ~count:10 start) in

  let next = match last with 
    | None -> None
    | Some float -> 
      let args =  ["start",Json_type.Build.string (string_of_float float)] in
      Some 
	(JsBase.to_event
	   (Js.More.fetch ~args
	      (input # reaction_url more)))
  in 
  
  let! items = ohm (Run.list_filter (render ctx details) items) in

  return (items, next)

(* Building the details url ---------------------------------------------------------------- *)

let details_url ctx input prefix id = 
  UrlR.build (ctx # instance) (input # segments) (prefix, `Item (IItem.decay id))

let list_url ctx input prefix = 
  UrlR.build (ctx # instance) (input # segments) (prefix, `List)

(* Displaying more items ------------------------------------------------------------------- *)
  
let more_reaction ~ctx ~folder = 
  O.Box.reaction "folder-more" begin fun self input (prefix,_) response ->
  
    let i18n = ctx # i18n in 
    let fail = return (Action.json (Js.More.return identity) response) in
    let details = details_url ctx input prefix in 

    let start_opt = 
      try match input # post "start" with
	| None -> None
	| Some str -> Some (float_of_string str)
      with _ -> None
    in
    
    let! start = req_or fail start_opt in
    
    (* Extracting the read-folder and the folder contents. *)
    let! read_folder = ohm_req_or fail (MFolder.Can.read folder) in
    
    let! (list, more) = ohm 
      (fetch_list ~start ~ctx ~folder:read_folder ~details input self ()) in
    
    let view =
      VFolder.More.render (object
	method more = more
	method list = list
      end) i18n
    in

    return (Action.json (Js.More.return view) response)
  end

(* Showing an uploaded file ---------------------------------------------------------------- *)

let postUpload_reaction ~ctx = 
  O.Box.reaction "post-upload" begin fun self input (prefix,_) response ->

    let cuid = IIsIn.user (ctx # myself) in

    let fail = return (Action.json ["error", Json_type.Bool true] response) in
    let wait = return (Action.json [] response) in
    
    let details = details_url ctx input prefix in 

    let! raw_fid = req_or     fail (input # post "id") in
    let! fid     = req_or     fail (CFile.get_doc_of_string cuid raw_fid) in
    let! iid     = ohm_req_or fail (MFile.item fid) in
    
    let! item    = ohm_req_or wait (MItem.try_get ctx iid) in

    let! show    = ohm_req_or wait (render ctx details item) in

    let html = VFolder.ListItem.render show (ctx # i18n) in

    return (Action.json (Js.Html.return html) response)

  end

(* List box -------------------------------------------------------------------------------- *)

let list_box ~ctx ~folder = 
  
  let! more_reaction = more_reaction ~ctx ~folder in
  let! postUpload_reaction = postUpload_reaction ~ctx in
  
  O.Box.leaf 
    begin fun input (prefix,_) ->
      
      let i18n = ctx # i18n in 
      
      let! read_folder_opt = ohm (MFolder.Can.read folder) in
      let! write_folder_opt = ohm (MFolder.Can.write folder) in
      
      let forbidden = return (VFolder.forbidden i18n) in
      let details = details_url ctx input prefix in

      let! read_folder = req_or forbidden read_folder_opt in
      
      let! (list, more) = ohm 
	(fetch_list ~ctx ~folder:read_folder ~details input more_reaction ()) in
      
      let upload = 
	match write_folder_opt with None -> None | Some write_folder ->
	  let fid = MFolder.Get.id write_folder in 
	  let ins = ctx # instance in 
	  Some (object
	    method cancel = UrlClient.cancel # build ins
	    method put    = (UrlFile.Client.put_doc ()) # build ins fid 
	    method get    = input # reaction_url postUpload_reaction
	    method title  = I18n.translate i18n (`label "folder.upload.title") 
	  end)
      in
      
      return (VFolder.Page.render (object
	method more    = more
	method list    = list
	method upload  = upload
      end) i18n)
    end

(* CItem details box ------------------------------------------------------------------------ *)

let item_box ~ctx ~folder ~item = 
  O.Box.leaf begin fun bctx (prefix,_) ->

    let back = list_url ctx bctx prefix in

    let result render = 
      return (VFolder.Item.render (object
	method contents = render
	method back     = back
      end) (ctx # i18n))
    in
    
    let missing = result (VFolder.Missing.render () (ctx # i18n)) in

    let! admin_folder_opt = ohm (MFolder.Can.admin folder) in
    let from =
      BatOption.map
	(fun folder -> `folder (MFolder.Get.id folder))
	admin_folder_opt
    in
    
    let! item = ohm_req_or missing (MItem.try_get ctx item) in

    let config = object
      method react  = true
      method chat _ = None
    end in 

    let! render = ohm (CItem.display ~ctx ~from ~config ~item) in
    result render

  end
    
(* The box itself -------------------------------------------------------------------------- *)

let box ~ctx ~folder =
  O.Box.decide 
    begin fun _ (_,contents) ->
      match contents with 
	| `List      -> return (list_box ~ctx ~folder)
	| `Item item -> return (item_box ~ctx ~folder ~item)
    end
  |> O.Box.parse CSegs.item_or_list
