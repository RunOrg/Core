(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open DMS_CDocument_common 

module Version = DMS_CDocument_version
module Admin   = DMS_CDocument_admin

let () = CClient.define Url.def_file begin fun access ->
  
  let  e404 = O.Box.fill (Asset_Client_PageNotFound.render ()) in

  let  actor = access # actor in 
  let! rid = O.Box.parse IRepository.seg in
  let! did = O.Box.parse IDocument.seg in 

  let! doc = ohm_req_or e404 $ MDocument.view ~actor did in
  let! adoc = ohm $ MDocument.Can.admin doc in 

  let! now = ohmctx (#time) in

  (* Render the download link for the latest version *)

  let! current = ohm begin 
    let  v = MDocument.Get.current doc in 
    let! url = ohm_req_or (return None) $ MFile.Url.get (v # file) `File in 
    let! author = ohm $ O.decay (CAvatar.mini_profile (v # author)) in
    return $ Some (object
      method version  = v # number
      method filename = v # filename
      method icon     = VIcon.of_extension (v # ext)
      method url      = url
      method time     = (v # time, now)
      method author   = author
    end)
  end in 

  (* Render the metadata for the file *) 

  let as_text = function 
    | Json.String value -> Some (return value) 
    | _ -> None
  in

  let as_date json = 
    match Date.of_json_safe json with 
      | Some d -> Some (AdLib.get (`WeekDate (Date.to_timestamp d)))
      | None -> None
  in

  let as_pick l json = 
    try let values = match json with 
          | Json.Array l -> List.map Json.to_string l 
	  | Json.String s -> [s] 
	  | _ -> [] in
	let values = BatList.filter_map begin fun s -> 
	    try Some (List.assoc s l) 
	    with _ -> None
	end values in
	if values = [] then None else Some begin
	  let! list = ohm $ Run.list_map AdLib.get values in
	  return (String.concat " ; " list)
	end
    with _ -> None
  in

  let! meta = ohm begin 
    let! meta = ohm (MDocMeta.get (MDocument.Get.id doc)) in
    let  data = MDocMeta.Get.data meta in
    if BatPMap.is_empty data then return [] else 
      let! metafields = ohm (MDocMeta.fields (access # iid)) in
      Run.list_filter begin fun (fieldkey, fieldinfo) -> 
	try let value = BatPMap.find fieldkey data in
	    let label = AdLib.write (fieldinfo # label) in
	    let value = match fieldinfo # kind with 
	      | `TextShort
	      | `TextLong -> as_text value 
	      | `Date -> as_date value
	      | `PickOne l 
	      | `PickMany l -> as_pick l value
	    in
	    match value with None -> return None | Some value -> 
  	      return (Some (object
		method label = label
		method value = value
	      end))
	with Not_found -> return None
      end metafields
  end in

  (* Render the task list for the file *)
  
  let! tasks = ohm $ MDocTask.All.by_document (MDocument.Get.id doc) in
  let! tasks = ohm $ Run.list_filter begin fun dtid -> 

    let! task = ohm_req_or (return None) (MDocTask.get dtid) in

    let  state, author, time = MDocTask.Get.theState task in
    let! author = ohm $ O.decay (CAvatar.mini_profile author) in 

    let  data = MDocTask.Get.data task in
    let  data = 
      let fields = MDocTask.Get.fields task in
      BatList.filter_map begin fun (fieldkey, fieldinfo) -> 
	try let value = BatPMap.find fieldkey data in
	    let label = AdLib.write (fieldinfo # label) in
	    let value = match fieldinfo # kind with 
	      | `TextShort
	      | `TextLong -> as_text value 
	      | `Date -> as_date value
	      | `PickOne l 
	      | `PickMany l -> as_pick l value
	    in
	    BatOption.map (fun value -> (object
		method label = label
		method value = value
	    end)) value 
	with Not_found -> None
      end fields
    in

    return (Some MDocTask.(object
      method process  = Get.label task
      method finished = Get.finished task 
      method time     = (time, now) 
      method state    = (PreConfig_Task.DMS.states (Get.process task)) # label state
      method author   = author
      method fields   = data
      method edit     = Action.url Url.Task.edit (access # instance # key)
	[ IRepository.to_string rid ; IDocument.to_string did ; IDocTask.to_string dtid ]
    end))
  end tasks in 

  (* Combine everything together *)

  O.Box.fill begin 
    Asset_DMS_Document.render (object
      method admin = match adoc with None -> None | Some _ ->  
	Some (object
	  method edit = Action.url Url.Doc.admin (access # instance # key)
	    [ IRepository.to_string rid ; IDocument.to_string did ]
	  method add = Action.url Url.Doc.version (access # instance # key) 
	    [ IRepository.to_string rid ; IDocument.to_string did ]
	end)	
      method name  = MDocument.Get.name doc 
      method current = current
      method meta = meta
      method tasks = tasks
      method newTask = Action.url Url.Task.create (access # instance # key) 
	[ IRepository.to_string rid ; IDocument.to_string did ]
    end)
  end 

end 
