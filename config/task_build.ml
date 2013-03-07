(* © 2013 RunOrg *)

open Common 
open Task_common 

(* Processes ------------------------------------------------------------------------------------------------ *)

let contexts () = 
  BatList.sort_unique compare (List.map (fun p -> p.p_context) (!processes))

let processId () = 
  String.concat "" (List.map begin fun ctx -> 
    "  module " ^ ctx  ^ " = Fmt.Make(struct type json t = [ "
    ^ String.concat "|" (List.map (fun p -> "`" ^ p.p_key) 
			   (List.filter (fun p -> p.p_context = ctx) (!processes)))
    ^ " ] end)\n" 
  end (contexts ()))

let label procs = 
  String.concat "" (List.map begin fun p ->
    "\n      | `" ^ p.p_key ^ " -> `PreConfig `" ^ p.p_label 
  end procs)

let pstates procs = 
  String.concat "" (List.map begin fun p ->
    "\n      | `" ^ p.p_key ^ " -> StateSet." ^ p.p_stateset
  end procs) 

let pfields procs = 
  String.concat "" (List.map begin fun p ->
    let fields = String.concat " ; " (List.map String.uncapitalize p.p_fields) in
    "\n      | `" ^ p.p_key ^ " -> Fields.([ " ^ fields ^ "])"
  end procs) 

let processes () = 
  String.concat "" (List.map begin fun ctx ->
    let procs = List.filter (fun p -> p.p_context = ctx) (!processes) in
    "module " ^ ctx ^ " = struct\n" 
    ^ "  let label  = function " ^ label  procs ^ "\n"
    ^ "  let states = function " ^ pstates procs ^ "\n"
    ^ "  let fields = function " ^ pfields procs ^ "\n"
    ^ "end\n"
  end (contexts ())) 

(* State sets ----------------------------------------------------------------------------------------------- *)

let initial ss = 
  match ss.ss_list with 
    | [] -> "Json.Null"
    | (key,_,_) :: _ -> Printf.sprintf "Json.String %S" key

let final ss = 
  "Json.String (" ^ String.concat "|" (List.map begin fun (key,_,_) ->
    Printf.sprintf "%S" key
  end (List.filter (fun (_,_,f) -> f) ss.ss_list)) ^ ") -> true | _ -> false"

let label ss = 
  String.concat "" (List.map begin fun (key,label,_) ->
    Printf.sprintf "\n      | Json.String %S -> Some (`PreConfig `%s)" key label
  end ss.ss_list) ^ "\n      | _ -> None"

let all ss = 
  String.concat "" (List.map begin fun (key,label,_) -> 
    Printf.sprintf "\n      Json.String %S, `PreConfig `%s ;" key label
  end ss.ss_list) 

let stateSets () = 
  String.concat "" (List.map begin fun ss ->
    "  let " ^ ss.ss_name ^ " = object\n"
    ^ "    method initial = "  ^ initial ss ^ "\n"
    ^ "    method final   = function " ^ final ss ^ "\n"
    ^ "    method label   = function " ^ label ss ^ "\n"
    ^ "    method all     = [ " ^ all ss ^ "\n    ]\n"
    ^ "  end\n"
  end (!statesets))

(* Fields --------------------------------------------------------------------------------------------------- *)

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
  | `PickOne  l -> "(`PickOne (" ^ pickable l ^ "))"
  | `PickMany l -> "(`PickMany (" ^ pickable l ^ "))"

let fields () =
  String.concat "" (List.map begin fun f ->
    Printf.sprintf "  let %s = %S, (object\n" (String.uncapitalize f.f_name) f.f_name
    ^ "    method label = `PreConfig `" ^ f.f_label ^ "\n"
    ^ "    method kind  = " ^ (kind f.f_type) ^ "\n"
    ^ "  end)\n"
  end (!fields))
      
let ml () = 
  "open Ohm\n"
  ^ "module ProcessId = struct\n" ^ processId () ^ "end\n\n"
  ^ "module StateSet = struct\n" ^ stateSets () ^ "end\n\n"
  ^ "module Fields = struct\n" ^ fields () ^ "end\n"
  ^ processes () 
