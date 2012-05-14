(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

let mail_i18n = MModel.I18n.load (Id.of_string "i18n-common-fr") `Fr

let with_self ~proof ~uid ~fail _cont = 

  let! proof = req_or fail proof in
  let! uid   = req_or fail uid   in

  let user_opt = uid
    |> IUser.of_string
    |> IUser.Deduce.from_login_token proof
  in

  let! user = req_or fail user_opt in

  let self = user 
    (* This is a core action. *)
    |> ICurrentUser.Assert.is_safe
    |> IUser.Deduce.is_self
  in

  _cont self 

  
