(* © 2013 RunOrg *)

open Common
open Atom_common

let ids natures = 
  String.concat " | " (List.map begin fun nature -> 
    "`" ^ nature.n_name
  end natures) 
    
let create_labels natures = 
  String.concat "" (List.map begin fun nature ->
    match nature.n_label_create with 
      | None -> Printf.sprintf "\n  | `%s -> None" nature.n_name
      | Some label -> Printf.sprintf "\n  | `%s -> Some (`PreConfig `%s)" nature.n_name label
  end natures)

let labels natures = 
  String.concat "" (List.map begin fun nature ->
    Printf.sprintf "\n  | `%s -> `PreConfig `%s" nature.n_name nature.n_label
  end natures)

let limited_labels natures = 
  String.concat "" (List.map begin fun nature ->
    Printf.sprintf "\n  | `%s -> `PreConfig `%s" nature.n_name nature.n_label_lim
  end natures)

let of_string natures = 
  String.concat "" (List.map begin fun nature ->
    Printf.sprintf "\n  | %S -> Some `%s" nature.n_name nature.n_name
  end natures) ^ "\n  | _ -> None" 

let to_string natures = 
  String.concat "" (List.map begin fun nature -> 
    Printf.sprintf "\n  | `%s -> %S" nature.n_name nature.n_name
  end natures)

let parents natures = 
  let rec get_parents accum nature = 
    List.fold_left (fun accum parent -> 
      if List.mem parent accum then accum else 
	try let nature' = List.find (fun n -> n.n_name = parent) natures in 
	    get_parents (parent :: accum) nature'
	with Not_found -> failwith ("Missing parent nature : " ^ parent)) accum nature.n_parents
  in
  String.concat "" (List.map begin fun nature ->
    let parents = get_parents [] nature in
    Printf.sprintf "\n  | `%s -> [%s]" nature.n_name 
      (String.concat ";" (List.map (Printf.sprintf "`%s") parents))
  end natures) 

let ml () = 
  let natures = !natures in 
  "open Ohm\n"
  ^ "module Id = struct\n"
  ^ "  include Fmt.Make(struct type json t = [ " ^ ids natures ^ " ] end)\n"
  ^ "  let of_string = function " ^ of_string natures ^ "\n" 
  ^ "  let to_string = function " ^ to_string natures ^ "\n"
  ^ "  let arg = to_string, of_string\n"
  ^ "end\n"
  ^ "let parents = function " ^ parents natures ^ "\n"
  ^ "let create_label = function " ^ create_labels natures ^ "\n"  
  ^ "let limited_label = function " ^ limited_labels natures ^ "\n"
  ^ "let label = function " ^ labels natures ^ "\n"
