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
    let! url = ohm_req_or (return None) $ MOldFile.Url.get (v # file) `File in 
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
    | Json.String value -> return (Some value) 
    | _                 -> return None
  in

  let as_date json = 
    match Date.of_json_safe json with 
      | Some d -> let! txt = ohm (AdLib.get (`WeekDate (Date.to_timestamp d))) in
		  return (Some txt) 
      | None   -> return None
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
	if values = [] then return None else 
	  let! list = ohm $ Run.list_map AdLib.get values in
	  return (Some (String.concat " ; " list))	    
    with _ -> return None
  in

  let as_atom json = 
    match json with 
      | Json.String _ -> MAtom.of_json ~actor:(access # actor) json
      | Json.Array  l -> let! list = ohm (Run.list_filter (MAtom.of_json ~actor:(access # actor)) l) in
			 return (Some (String.concat " ; " list))
      | _ -> return None
  in

  let! meta = ohm begin 
    let! meta = ohm (MDocMeta.get (MDocument.Get.id doc)) in
    let  data = MDocMeta.Get.data meta in
    if BatPMap.is_empty data then return [] else 
      let! metafields = ohm (MDocMeta.fields (access # iid)) in
      Run.list_filter begin fun (fieldkey, fieldinfo) -> 
	try let value = BatPMap.find fieldkey data in
	    let label = AdLib.write (fieldinfo # label) in
	    let! value = ohm begin match fieldinfo # kind with 
	      | `TextShort
	      | `TextLong   -> as_text value
	      | `Date       -> as_date value
	      | `PickOne  l 
	      | `PickMany l -> as_pick l value
	      | `AtomOne  _ 
	      | `AtomMany _ -> as_atom value
	    end in
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
    let! data = ohm begin 
      let fields = MDocTask.Get.fields task in      
      Run.list_filter begin fun (fieldkey, fieldinfo) -> 
	try let value = BatPMap.find fieldkey data in
	    let label = AdLib.write (fieldinfo # label) in
	    let! value = ohm begin match fieldinfo # kind with 
	      | `TextShort
	      | `TextLong -> as_text value 
	      | `Date -> as_date value
	      | `PickOne l 
	      | `PickMany l -> as_pick l value
	    end in
	    return (BatOption.map (fun value -> (object
	      method label = label
	      method value = value
	    end)) value) 
	with Not_found -> return None
      end fields
    end in

    let! assignee = ohm $ O.decay (Run.opt_map CAvatar.mini_profile (MDocTask.Get.assignee task)) in
    let! notified = ohm $ O.decay (Run.list_map CAvatar.mini_profile (MDocTask.Get.notified task)) in

    return (Some MDocTask.(object
      method process  = Get.label task
      method finished = Get.finished task 
      method time     = (time, now) 
      method assignee = assignee
      method notified = notified
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
      method back = Action.url Url.see (access # instance # key) [ IRepository.to_string rid ]
      method edit = if adoc = None then None else 
	  Some (Action.url Url.Doc.admin (access # instance # key)
		  [ IRepository.to_string rid ; IDocument.to_string did ])

      method add = if adoc = None then None else 
	  Some (Action.url Url.Doc.version (access # instance # key) 
		  [ IRepository.to_string rid ; IDocument.to_string did ])
      method name  = MDocument.Get.name doc 
      method current = current
      method meta = meta
      method tasks = tasks
      method newTask = Action.url Url.Task.create (access # instance # key) 
	[ IRepository.to_string rid ; IDocument.to_string did ]
    end)
  end 

end 
