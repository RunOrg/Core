(* © 2013 RunOrg *)

open Ohm
open BatPervasives

let on_update_call,     on_update     = Sig.make (Run.list_iter identity)
let on_obliterate_call, on_obliterate = Sig.make (Run.list_iter identity)
let refresh_grant_call, refresh_grant = Sig.make (Run.list_iter identity)
