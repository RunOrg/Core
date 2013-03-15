(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

(* Render an individual metafield *)
let render ~fieldkey ~fieldinfo = 

  let label = AdLib.get (fieldinfo # label) in

  let seed data = try BatPMap.find fieldkey data with Not_found -> Json.Null in

  (* String fields *)

  let seed_string s = 
    match seed s with 
      | Json.String s -> return s
      | _ -> return ""
  in

  let parse_string _ s = 
    let s = BatString.trim s in
    if s = "" then return (Ok Json.Null) else return (Ok (Json.String s))
  in

  (* Date fields *)

  let seed_date s = 
    match Date.of_json_safe (seed s) with 
      | Some d -> return (Date.to_compact d)
      | None -> return ""
  in
  
  let parse_date _ s = 
    match Date.of_compact s with 
      | Some d -> return (Ok (Date.to_json d))
      | None -> return (Ok (Json.Null))
  in

  (* Pickers *)

  let format = Fmt.String.fmt in

  let source list = 
    List.map (fun (k,v) -> k, AdLib.write v) list
  in

  let seed_pickone s = 
    match try Json.to_list (Json.to_string) (seed s) with _ -> [] with
      | h :: _ -> return (Some h)
      | [] -> return None
  in

  let seed_pickmany s = 
    return (try Json.to_list (Json.to_string) (seed s) with _ -> [])
  in

  let parse_pickone _ = function
    | Some s -> return (Ok (Json.String s))
    | None -> return (Ok Json.Null)
  in

  let parse_pickmany _ l = 
    return (Ok (Json.of_list Json.of_string l))
  in

  match fieldinfo # kind with 
    | `Date       -> VEliteForm.date ~label seed_date parse_date
    | `TextShort  -> VEliteForm.text ~label seed_string parse_string
    | `TextLong   -> VEliteForm.textarea ~label seed_string parse_string
    | `PickOne  l -> VEliteForm.radio ~label ~format ~source:(source l) seed_pickone parse_pickone
    | `PickMany l -> VEliteForm.checkboxes ~label ~format ~source:(source l) seed_pickmany parse_pickmany
