(* © 2013 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

let empty access atid = 
  O.Box.fill (Asset_Client_PageNotFound.render ()) 

(* Filter management *)

let filters = ref ([])

let addFilter ~key ~label ~body = 
  filters := (key, (label, body)) :: !filters

let () = 
  addFilter ~key:"avatars"     ~label:`Atom_Filter_Avatars     ~body:empty ;
  addFilter ~key:"groups"      ~label:`Atom_Filter_Groups      ~body:empty ;
  addFilter ~key:"events"      ~label:`Atom_Filter_Events      ~body:empty ;
  addFilter ~key:"discussions" ~label:`Atom_Filter_Discussions ~body:empty 

let filters = lazy (List.rev !filters) 

(* View core *)

let () = CClient.define UrlClient.Atom.def_view begin fun access -> 

  let  filters = Lazy.force filters in 

  let! atid = O.Box.parse IAtom.seg in 
  let! filter = O.Box.parse OhmBox.Seg.string in 

  let  filter, (_,box) = try List.find (fst |- (=) filter) filters with Not_found -> List.hd filters in 
  let! box = O.Box.add (box access atid) in 

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
      method body = return (O.Box.render box)
    end)
    
  end 

end 
