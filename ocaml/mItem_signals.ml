(* © 2012 RunOrg *)

open Ohm
open BatPervasives

let on_post_call,       on_post       = Sig.make (Run.list_iter identity)
let on_obliterate_call, on_obliterate = Sig.make (Run.list_iter identity)
