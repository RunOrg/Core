(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let session = "R"

let start cuid res = 

  let id, proof = match cuid with 
    | `New cuid -> ICurrentUser.to_string cuid, 
                   IUser.Deduce.make_new_session_token cuid 
    | `Old cuid -> ICurrentUser.to_string cuid, 
                   IUser.Deduce.make_old_session_token cuid
  in

  let token = id ^ "-" ^ proof in
  Action.with_cookie ~name:session ~value:token ~life:0 res

let check req = 
  let! cookie     = req_or `None (req # cookie session) in
  let! uid, proof = nothrow_or `None (lazy (BatString.split cookie "-")) in
  let  uid = IUser.of_string uid in
  IUser.Deduce.from_session_token proof uid 

let close res = 
  Action.with_cookie ~name:session ~value:"" ~life:0 res

let decay = function 
  | `None -> None
  | `New cuid -> Some (ICurrentUser.decay cuid) 
  | `Old cuid -> Some (ICurrentUser.decay cuid) 
