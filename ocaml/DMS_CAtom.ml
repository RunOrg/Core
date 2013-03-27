(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let query ~count ?start access atid = 

  let start = BatOption.bind DMS_IDocument.of_json_safe start in
  let! list, next = ohm (DMS_MDocument.Search.by_atom ~actor:(access # actor) ?start ~count atid) in

  let! htmls = ohm $ Run.list_filter (fun doc -> 
    
    let  did = DMS_IDocument.decay (DMS_MDocument.Get.id doc) in
    
    let! repos = ohm $ 
      Run.list_filter (DMS_MRepository.view ~actor:(access # actor)) (DMS_MDocument.Get.repositories doc) in
    
    (* Need to "see" the document in at least one repository, so we can generate a 
       view link. *)
    let! rid = req_or (return None) (match repos with 
      | [] -> None
      | h :: t -> Some (DMS_MRepository.Get.id h)) in       

    let! html = ohm $ Asset_DMS_SearchResult.render (object
      method url  = Action.url DMS_Url.file (access # instance # key) 
	[ DMS_IRepository.to_string rid ; DMS_IDocument.to_string did ]
      method name = DMS_MDocument.Get.name doc 
      method repos = List.map DMS_MRepository.Get.name repos
    end) in

    return (Some html) 

  ) list in

  return (htmls, BatOption.map DMS_IDocument.to_json next)

let () = CAtom.View.addFilter ~key:"dms-docs" ~label:`DMS_Atom_Filter ~query
