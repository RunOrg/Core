(* © 2012 RunOrg *)

open BatPervasives
open MVote_common

let on_create_call, on_create = Ohm.Sig.make (Ohm.Run.list_iter identity)
