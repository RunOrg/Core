(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let count = 8

let search more ?start access atid = 
  let! list, next = ohm (DMS_MDocument.Search.by_atom ~actor:(access # actor) ?start ~count atid) in
  let! htmls = ohm $ Run.list_map (fun doc -> 
    let did = DMS_IDocument.decay (DMS_MDocument.Get.id doc) in
    Asset_DMS_SearchResult.render (object
      method url  = Action.url DMS_Url.Doc.inrepo (access # instance # key) did
      method name = DMS_MDocument.Get.name doc 
    end)
  ) list in
  return (Html.concat htmls)

let body access atid = 
  O.Box.fill (search () access atid)

let () = CAtom.View.addFilter ~key:"dms-docs" ~label:`DMS_Atom_Filter ~body
