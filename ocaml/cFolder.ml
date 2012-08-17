(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let render access item = 
  let! doc = req_or (return None) begin match item # payload with 
    | `Doc   d -> Some d
    | _        -> None
  end in
  let! download = ohm_req_or (return None) $ MFile.Url.get (doc # file) `File in
  let! now = ohmctx (#time) in
  let  ext = VIcon.of_extension (doc # ext) in
  let! author = ohm $ CAvatar.name (doc # author) in
  return $ Some (object
    method ext      = ext
    method name     = doc # title
    method info     = "javascript:void(0)"
    method download = download
    method size     = doc # size
    method author   = author
    method date     = (item # time, now) 
    method comments = if item # ncomm = 0 then None else Some item # ncomm 
  end)
 
let items more access folder start = 
  let! items, next = ohm $ MItem.list ~self:(access # self) (`folder (MFolder.Get.id folder)) ~count:9 start in
  let! items = ohm $ Run.list_filter (render access) items in 
  let  more  = match next with 
    | None      -> None
    | Some time -> Some (OhmBox.reaction_endpoint more time,Json.Null)
  in
  return (items, more)

let folder_rw more access folder wfolder = 
  O.Box.fill begin 
    let! files, more = ohm $ O.decay (items more access folder None) in 
    Asset_Folder_List.render (object
      method files = files
      method more  = more
    end)
  end

let folder_ro more access folder = 
  let! files, more = ohm $ O.decay (items more access folder None) in 
  O.Box.fill (Asset_Folder_List.render (object
    method files = files
    method more  = more
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

let box access folder =
  match folder with
    | None -> folder_none () 
    | Some folder -> let! writable = ohm (O.decay (MFolder.Can.write folder)) in
		    let! more = O.Box.react Fmt.Float.fmt (getmore access folder) in 
		    match writable with 
		      | None         -> folder_ro more access folder
		      | Some wfolder -> folder_rw more access folder wfolder
			
