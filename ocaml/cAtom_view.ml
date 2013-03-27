(* © 2013 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

let empty ~count ?start access atid = 
  return ([], None)

(* Filter management *)

type query = 
    count:int
 -> ?start:Ohm.Json.t 
 -> [`Token] CAccess.t
 -> IAtom.t 
 -> (Ohm.Html.writer list * Ohm.Json.t option) O.run

let filters = ref ([] : (string * (O.i18n * query)) list)

let addFilter ~key ~label ~query = 
  filters := (key, (label, query)) :: !filters

let () = 
  addFilter ~key:"avatars"     ~label:`Atom_Filter_Avatars     ~query:empty ;
  addFilter ~key:"groups"      ~label:`Atom_Filter_Groups      ~query:empty ;
  addFilter ~key:"events"      ~label:`Atom_Filter_Events      ~query:empty ;
  addFilter ~key:"discussions" ~label:`Atom_Filter_Discussions ~query:empty 

let filters = lazy (List.rev !filters) 

(* View core *)

let () = CClient.define UrlClient.Atom.def_view begin fun access -> 

  let  filters = Lazy.force filters in 

  let! atid = O.Box.parse IAtom.seg in 
  let! filter = O.Box.parse OhmBox.Seg.string in 

  O.Box.fill begin 

    let missing = Asset_Client_PageNotFound.render () in

    let! atom = ohm_req_or missing (MAtom.get ~actor:(access # actor) atid) in
    
    let! filters = ohm $ Run.list_map begin fun (filter', (label, _)) -> 
      let! url = ohm (O.Box.url [ IAtom.to_string atid ; filter' ]) in
      let! label = ohm (AdLib.get label) in
      return (object
	method sel = filter = filter'
	method name = label
	method url = url 
      end)
    end filters in 

    Asset_Atom_Wrap.render (object
      method title = atom # label 
      method filters = filters
      method body = return (Html.str "")
    end)
    
  end 

end 
