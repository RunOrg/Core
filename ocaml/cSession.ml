(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let session = "R"

let start uid res = 
  let proof = IUser.Deduce.make_login_token uid in
  let token = IUser.to_string uid ^ "-" ^ proof in
  Action.with_cookie ~name:session ~value:token ~life:0 res

let check req = 
  let! cookie     = req_or None (req # cookie session) in
  let! uid, proof = nothrow_or None (lazy (BatString.split cookie "-")) in
  let  uid = IUser.of_string uid in
  IUser.Deduce.from_login_token proof uid

let close res = 
  Action.with_cookie ~name:session ~value:"" ~life:0 res
