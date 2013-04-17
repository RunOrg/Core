(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let render ?moderate access item = 

  let! doc = req_or (return None) begin match item # payload with 
    | `Doc   d -> Some d
    | _        -> None
  end in
  let! download = ohm_req_or (return None) $ MOldFile.Url.get (doc # file) `File in

  let! now = ohmctx (#time) in

  let  ext = VIcon.of_extension (doc # ext) in

  let! avatar = ohm $ CAvatar.mini_profile (doc # author) in

  let remove = match item # own with 
    | Some own -> Some (object
      method url = Action.url UrlClient.Item.remove (access # instance # key) 
	( let cuid = MActor.user (access # actor) in
	  let proof = IItem.Deduce.(make_remove_token cuid (own_can_remove own)) in
	  (IItem.decay (item # id), proof) ) 
    end)
    | None -> match moderate with 
	| Some f -> Some (object method url = f (IItem.decay (item # id)) end)
	| None   -> None
  in

  return $ Some (object
    method ext      = ext
    method name     = doc # title
    method download = download
    method size     = doc # size
    method author   = avatar # name
    method pic      = avatar # pico
    method date     = (item # time, now)
    method del      = remove
    method comments = if item # ncomm = 0 then None else Some item # ncomm 
  end)
 
let items more access folder start = 
  let! items, next = ohm $ MItem.list ~self:(access # self) (`folder (MFolder.Get.id folder)) ~count:9 start in
  let! admin = ohm $ MFolder.Can.admin folder in
  let  moderate = 
    if admin = None then None else 
      Some (Action.url UrlClient.Item.moderate (access # instance # key))  
  in
  let! items = ohm $ Run.list_filter (render ?moderate access) items in 
  let  more  = match next with 
    | None      -> None
    | Some time -> Some (OhmBox.reaction_endpoint more time,Json.Null)
  in
  return (items, more)

let folder_rw ~compact more access folder wfolder = 
  O.Box.fill begin 
    let! files, more = ohm $ O.decay (items more access folder None) in 
    let upload = Action.url UrlUpload.Client.Doc.root (access # instance # key) 
      (IFolder.decay $ MFolder.Get.id folder) in
    Asset_Folder_List.render (object
      method upload = Some upload
      method files  = files
      method more   = more
      method compact = compact
    end)
  end

let folder_ro ~compact more access folder = 
  let! files, more = ohm $ O.decay (items more access folder None) in 
  O.Box.fill (Asset_Folder_List.render (object
    method upload = None
    method files  = files
    method more   = more
    method compact = compact 
  end))

let folder_none () = 
  O.Box.fill (Asset_Folder_ListNone.render ())

let getmore access folder = begin fun time _ self res -> 
  let! files, more = ohm $ O.decay (items self access folder (Some time)) in
  let! html = ohm $ Asset_Folder_More.render (object
    method files = files
    method more  = more
  end) in
  return $ Action.json ["more", Html.to_json html] res
end

let box ?(compact=false) access folder =
  match folder with
    | None -> folder_none () 
    | Some folder -> let! writable = ohm (O.decay (MFolder.Can.write folder)) in
		     let! more = O.Box.react Fmt.Float.fmt (getmore access folder) in 
		     match writable with 
		       | None         -> folder_ro ~compact more access folder
		       | Some wfolder -> folder_rw ~compact more access folder wfolder
			 
