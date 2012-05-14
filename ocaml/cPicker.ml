(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

type 't result = 
  | Node of string * string * 't
  | CItem of string * string * JsCode.t 

let node ~icon ~title from = 
  Node (icon, title, from)

let item ~icon ~title js = 
  CItem (icon, title, js)

module type TREE = sig

  type t 
  type param
    
  val of_json : Json_type.t -> t
  val to_json : t -> Json_type.t

  val node : param -> I18n.t -> t -> t result list O.run

end

module Make = functor (Tree:TREE) -> struct

  let _at_node ~node ~param ~me ~url i18n = 
    let url string = 
      url (ConfigKey.prove ["picker";ICurrentUser.to_string me;string]^"-"^string) in
    Tree.node param i18n node
    |> Run.map begin fun list ctx ->
      List.fold_left begin fun ctx result -> 
	match result with 
	  | CItem (icon,title,action) -> VPicker.item ~action ~icon ~title ~i18n ctx
	  | Node (icon,title,from)   -> 
	    let url = url (Json_io.string_of_json ~recursive:true ~compact:true (Tree.to_json from)) in
	    VPicker.async_section ~url ~icon ~title ~i18n ctx
      end ctx list
    end	  

  let at_root ~root ~param ~me ~url ~i18n = 
    _at_node ~node:root ~param ~me ~url i18n 
    |> Run.map begin fun contents ctx ->
      VPicker.picker
	~contents
	~i18n
	ctx
    end

  let at_node ~arg ~param ~me ~url ~i18n = 
    try 
      let proof, json = BatString.split arg "-" in
      if ConfigKey.is_proof proof ["picker";ICurrentUser.to_string me;json] then 
	let node = Tree.of_json (Json_io.json_of_string ~recursive:true json) in       
	_at_node ~node ~param ~me ~url i18n |> Run.map (fun x -> Some x)
      else
	return None
    with _ -> 
      return None

end
