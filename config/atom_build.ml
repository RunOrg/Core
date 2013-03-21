(* © 2013 RunOrg *)

open Common
open Atom_common

let ids natures = 
  String.concat " | " (List.map begin fun nature -> 
    "`" ^ nature.n_name
  end natures) 
    
let create_labels natures = 
  String.concat "" (List.map begin fun nature ->
    Printf.sprintf "\n  | `%s -> `PreConfig `%s" nature.n_name nature.n_label_create
  end natures)
 
let of_string natures = 
  String.concat "" (List.map begin fun nature ->
    Printf.sprintf "\n  | %S -> Some `%s" nature.n_name nature.n_name
  end natures) ^ "\n  | _ -> None" 

let to_string natures = 
  String.concat "" (List.map begin fun nature -> 
    Printf.sprintf "\n  | `%s -> %S" nature.n_name nature.n_name
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
  ^ "let create_label = function " ^ create_labels natures ^ "\n"
