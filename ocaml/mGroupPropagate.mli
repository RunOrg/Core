(* © 2012 RunOrg *)

module Diff : Ohm.JoyA.FMT with type t = 
  <
    action : [`add | `remove] ;
    src : string ;
    dest : string
  >

val names : Diff.t -> (string * string) list 

val apply :
     (src:[`Bot] IGroup.id -> dest:[`Bot] IGroup.id -> [`add|`remove] -> unit O.run)
  -> MPreConfigNamer.t
  -> Diff.t
  -> unit O.run

module Entity : sig

  module Diff : Ohm.JoyA.FMT with type t = 
    <
      action : [`add | `remove] ;
      dest : string  
    >

  val names : Diff.t -> (string * string) list 
    
  val apply_diffs :
       IGroup.t list
    -> MPreConfigNamer.t
    -> Diff.t list
    -> IGroup.t list O.run

end
