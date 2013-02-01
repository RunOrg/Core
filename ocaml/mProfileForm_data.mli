(* © 2013 RunOrg *)

type data = (string * Ohm.Json.t) list 

val set : 'any IProfileForm.id -> MUpdateInfo.t -> data -> unit O.run
val get : 'any IProfileForm.id -> data O.run 
