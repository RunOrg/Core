(* © 2013 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

module View = CAtom_view

(* Plug-in registration ------------------------------------------------------------------------------------- *)

let plugins = ref BatPMap.empty 

let register ?render ~search nature = 
  plugins := BatPMap.add nature (render, search) !plugins

let render nature default = 
  try BatOption.default default (BatPMap.find nature !plugins |> fst)
  with Not_found -> default

let search nature default = 
  try BatPMap.find nature !plugins |> snd
  with Not_found -> default

(* Listing atoms in search fields --------------------------------------------------------------------------- *)

let () = UrlClient.def_atom $ CClient.action begin fun access req res ->

  let result list =   
    let! json = ohm $ VEliteForm.Picker.formatResults MAtom.PublicFormat.fmt list in
    return (Action.json json res)
  in

  let! json = req_or (result []) (Action.Convenience.get_json req) in
  let! mode = req_or (result []) (VEliteForm.Picker.QueryFmt.of_json_safe json) in
  
  let  nature = req # args in

  let  display atom = 
    let render = 
      render (atom # nature) (fun _ atom -> return (Html.esc (atom # label))) (access # actor) atom in
    (`Saved (atom # id), render) 
  in

  let  limited id nature = 
    (`Saved id, AdLib.write (PreConfig_Atom.limited_label nature))
  in

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
    let! list   = ohm $ MAtom.All.suggest (access # actor) ?nature ~count prefix in 
    let  list   = List.map display list in 
    result (match create nature prefix with 
      | Some create -> list @ [create]
      | None        -> list) 
  in

  let by_json atids = 
    let  atids = BatList.filter_map MAtom.PublicFormat.of_json_safe atids in 
    let! list = ohm $ Run.list_filter begin function 
      | `Unsaved (n,label) -> return (create (Some n) label)
      | `Saved atid -> let! atom = ohm (MAtom.get (access # actor) atid) in 
		       match atom with 
 		       | `Some atom -> return (Some (display atom))
		       | `Missing -> return None
		       | `Limited nature -> return (Some (limited atid nature))
    end atids in 
    result list
  in

  match mode with 
    | `ByJson   aids   -> by_json aids
    | `ByPrefix prefix -> by_prefix prefix
  
end 

(* Redirect to appropriate atom viewing page ---------------------------------------------------------------- *)

let () = UrlClient.def_viewAtom $ CClient.action begin fun access req res ->

  let! json = req_or (return res) (Action.Convenience.get_json req) in
  let! atid = req_or (return res) (MAtom.PublicFormat.of_json_safe json) in 

  let! atid = req_or (return res) (match atid with 
    | `Saved atid -> Some atid
    | `Unsaved _ -> None) in

  let key = access # instance # key in

  let default _ key atid = return (Action.url UrlClient.Atom.view key [ IAtom.to_string atid ]) in
  let result  url  = let! url = ohm url in 
		     return (Action.javascript (Js.redirect url ()) res) in

  let! atom = ohm (MAtom.get ~actor:(access # actor) atid) in
  match atom with 
    | `Some atom -> result (search (atom # nature) default (access # actor) key atid) 
    | `Missing 
    | `Limited _ -> result (default (access # actor) key atid) 

end
