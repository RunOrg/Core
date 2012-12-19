(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let () = 
  let! eid = Sig.listen MEvent.Signals.on_bind_inboxLine in
  return () 
