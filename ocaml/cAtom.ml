(* © 2012 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

module View = CAtom_view

let () = UrlClient.def_atom $ CClient.action begin fun access req res ->

  let result list =   
    let! json = ohm $ VEliteForm.Picker.formatResults MAtom.PublicFormat.fmt list in
    return (Action.json json res)
  in

  let! json = req_or (result []) (Action.Convenience.get_json req) in
  let! mode = req_or (result []) (VEliteForm.Picker.QueryFmt.of_json_safe json) in
  
  let  iid    = IInstance.decay (access # iid) in
  let  nature = req # args in

  let  display atom = (`Saved (atom # id), return (Html.esc (atom # label))) in

  let  create n label =
    match n with None -> None | Some n -> 
      if label = "" then None else 
	match PreConfig_Atom.create_label n with None -> None | Some create ->	  
	  Some (
	    `Unsaved (n,label), 
	    Asset_Atom_Create.render (object
	      method create = AdLib.write create
	      method name   = label
	    end))
  in

  let by_prefix prefix =
    let  prefix = BatString.strip prefix in
    let  count  = 10 in
    let! list   = ohm $ MAtom.All.suggest iid ?nature ~count prefix in 
    let  list   = List.map display list in 
    result (match create nature prefix with 
      | Some create -> list @ [create]
      | None        -> list) 
  in

  let by_json atids = 
    let  atids = BatList.filter_map MAtom.PublicFormat.of_json_safe atids in 
    let! list = ohm $ Run.list_filter begin function 
      | `Saved atid -> let! atom = ohm_req_or (return None) (MAtom.get (access # actor) atid) in 
		       return (Some (display atom))
      | `Unsaved (n,label) -> return (create (Some n) label)
    end atids in 
    result list
  in

  match mode with 
    | `ByJson   aids   -> by_json aids
    | `ByPrefix prefix -> by_prefix prefix
  
end 

let () = UrlClient.def_viewAtom $ CClient.action begin fun access req res ->

  let! json = req_or (return res) (Action.Convenience.get_json req) in
  let! atid = req_or (return res) (MAtom.PublicFormat.of_json_safe json) in 

  let! atid = req_or (return res) (match atid with 
    | `Saved atid -> Some atid
    | `Unsaved _ -> None) in

  let url = Action.url UrlClient.Atom.view (access # instance # key) [ IAtom.to_string atid ] in

  return (Action.javascript (Js.redirect url ()) res)

end
