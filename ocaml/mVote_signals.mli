(* © 2012 RunOrg *)

open MVote_common

val on_create_call : ([`Unknown] vote, unit O.run) Ohm.Sig.listener
val on_create      : ([`Unknown] vote, unit O.run) Ohm.Sig.channel 
