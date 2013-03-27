(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let query ~count ?start access atid = 
  let start = BatOption.bind DMS_IDocument.of_json_safe start in
  let! list, next = ohm (DMS_MDocument.Search.by_atom ~actor:(access # actor) ?start ~count atid) in
  let! htmls = ohm $ Run.list_map (fun doc -> 
    let did = DMS_IDocument.decay (DMS_MDocument.Get.id doc) in
    Asset_DMS_SearchResult.render (object
      method url  = Action.url DMS_Url.Doc.inrepo (access # instance # key) did
      method name = DMS_MDocument.Get.name doc 
    end)
  ) list in
  return (htmls, BatOption.map DMS_IDocument.to_json next)

let () = CAtom.View.addFilter ~key:"dms-docs" ~label:`DMS_Atom_Filter ~query
