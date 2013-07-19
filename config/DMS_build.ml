(* © 2013 RunOrg *)

open DMS_common

let adlib a = 
  Printf.sprintf "(`PreConfig `%s)" a 

let pickable l = 
  Printf.sprintf 
    "[ %s ]"
    (String.concat " ; " (List.map (fun (key,label) ->
      Printf.sprintf "%S, %s" key (adlib label)) l))

let kind = function 
  | `TextShort  -> "`TextShort"
  | `TextLong   -> "`TextLong"
  | `Date       -> "`Date"
  | `AtomOne  n -> "(`AtomOne `" ^ n ^ ")"
  | `AtomMany n -> "(`AtomMany `" ^ n ^ ")"
  | `PickOne  l -> "(`PickOne (" ^ pickable l ^ "))"
  | `PickMany l -> "(`PickMany (" ^ pickable l ^ "))"

let field f = 
  Printf.sprintf "(%S,(object val l = %s val k = %s method label = l method kind = k end))"
    f.key
    (adlib f.label)
    (kind f.kind)

let fieldmap () = 
  Printf.sprintf "let fieldmap = List.fold_left (fun m (k,v) -> BatMap.add k v m) BatMap.empty [ %s ]"
    (String.concat ";" (List.map field (!fields))) 

let fieldcheck key = 
  List.exists (fun f -> f.key = key) (!fields) 

let fieldfind key = 
  Printf.sprintf "%S, BatMap.find %S fieldmap" key key

let fieldset (name,keys) = 
  Printf.sprintf "let fs%s : fs = [ %s ]" name
    (String.concat ";" (List.map fieldfind (List.filter fieldcheck keys)))

let fmt () = 
  "include Fmt.Make(struct type json t = [" 
  ^ (String.concat "|" (List.map (fun (t,_) -> "`" ^ t) (!fieldsets)))
  ^ "] end)"
    
let allfieldsets () = 
  "module Metadata = struct\n"
  ^ fmt () 
  ^ " "
  ^ fieldmap () 
  ^ " "
  ^ String.concat " " (List.map fieldset (!fieldsets))
  ^ " end\n"

let metadata () = 
  "let metadata = function"
  ^ (String.concat "" (List.map (fun (t,_) -> Printf.sprintf " | `%s -> Metadata.fs%s" t t) (!fieldsets)))

let fstype () =  
  "type fs = (string * < kind : [ `Date
                                | `PickOne  of (string * O.i18n) list
                                | `PickMany of (string * O.i18n) list
                                | `AtomOne  of IAtom.Nature.t
                                | `AtomMany of IAtom.Nature.t
                                | `TextLong
                                | `TextShort ];
              label : O.i18n >) list "

let ml () = 
  "open Ohm\n" ^ fstype () ^  allfieldsets () ^ " " ^ metadata () 
