(* © 2013 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

module E         = MGroup_core
module Can       = MGroup_can 

include HEntity.Atom(Can)(E)(struct
  type t = E.t
  let key    = "group"
  let nature = `Group
  let limited t = match t.E.vision with 
    | `Public 
    | `Normal -> false
    | `Private -> true
  let hide t = false
  let name t = match t.E.name with 
    | Some n -> TextOrAdlib.to_string n
    | None   -> AdLib.get `Group_Unnamed
end) 

