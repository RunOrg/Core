(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

let on_bind_inboxLine_call, on_bind_inboxLine = Sig.make (Run.list_iter identity)
let on_update_call, on_update = Sig.make (Run.list_iter identity)
let on_bind_group_call, on_bind_group = Sig.make (Run.list_iter identity)
