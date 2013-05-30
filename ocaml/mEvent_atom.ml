(* © 2013 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

module E         = MEvent_core
module Can       = MEvent_can 

include HEntity.Atom(Can)(E)(struct
  type t = E.t
  let key    = "event"
  let nature = `Event
  let limited t = 
    if t.E.draft then true else 
      match t.E.vision with 
        | `Public 
	| `Normal -> false
	| `Private -> true
  let hide t = false
  let name t = match t.E.name with 
    | Some n -> return n 
    | None   -> AdLib.get `Event_Unnamed
end) 
