(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open O

let name = 
  match O.environment with
    | `Dev  -> "DEV_RUNORG_SESSION"
    | `Prod ->     "RUNORG_SESSION"

let with_login_cookie user remember response = 
  let cookie_time   = if remember then 3600 * 48 else 0 in
  let cookie_keep   = if remember then "r" else "d" in
  let cookie_name   = name in
  let cookie_user   = IUser.to_string user in
  let cookie_proof  = IUser.Deduce.make_login_token user in 
  let cookie_value  = cookie_keep ^ "-" ^ cookie_user ^ "-" ^ cookie_proof in
  Action.with_cookie ~name:cookie_name ~value:cookie_value ~life:cookie_time response

let with_logout_cookie response = 
  let cookie_time   = 1 in
  let cookie_name   = name in
  let cookie_value  = "-" in 
  Action.with_cookie ~name:cookie_name ~value:cookie_value ~life:cookie_time response

let unverified_user_id cookie = 
  match BatString.nsplit cookie "-" with
    | [ _ ; user ; _ ] -> Some (IUser.of_string user)
    | _                -> None
      
let get_login_cookie cookie = 
  match BatString.nsplit cookie "-" with
    | [ _ ; user ; proof ] ->
      IUser.Deduce.from_login_token proof (IUser.of_string user) 
    | _ -> None

let read_login_cookie cookie ~success ~fail response =  
  match 
    match BatString.nsplit cookie "-" with
    | [ keep ; user ; proof ] ->
      begin match IUser.Deduce.from_login_token proof (IUser.of_string user) with
	| Some user -> Some (user,keep)
	| None -> None
      end 
    | _ -> None
  with None -> fail response | Some (user,keep) -> 
    let self   = IUser.Deduce.current_can_login user in
    let rembr  = keep = "r" in
    success user (with_login_cookie self rembr response)

let tracker =
  match O.environment with
    | `Dev  -> "DEV_R"
    | `Prod ->     "R"

let with_tracking_cookie request callback =

  let value =
    match request # cookie tracker with
      | Some value -> value
      | None -> Util.uniq ()
  in

  let response = callback value in 

  Action.with_cookie ~name:tracker ~value ~life:(3600 * 24 * 365) response

