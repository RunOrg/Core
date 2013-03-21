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
 
let ml () = 
  let natures = !natures in 
  "open Ohm\n"
  ^ "module Id = Fmt.Make(struct type json t = [ " ^ ids natures ^ " ] end)\n"
  ^ "let create_label = function " ^ create_labels natures ^ "\n"
