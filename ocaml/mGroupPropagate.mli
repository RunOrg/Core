(* © 2013 RunOrg *)

module Diff : Ohm.Fmt.FMT with type t = 
  <
    action : [`add | `remove] ;
    src : string ;
    dest : string
  >

val names : Diff.t -> (string * string) list 

val apply :
     (src:[`Bot] IAvatarSet.id -> dest:[`Bot] IAvatarSet.id -> [`add|`remove] -> unit O.run)
  -> MPreConfigNamer.t
  -> Diff.t
  -> unit O.run

module Entity : sig

  module Diff : Ohm.Fmt.FMT with type t = 
    <
      action : [`add | `remove] ;
      dest : string  
    >

  val names : Diff.t -> (string * string) list 
    
  val apply_diffs :
       IAvatarSet.t list
    -> MPreConfigNamer.t
    -> Diff.t list
    -> IAvatarSet.t list O.run

end
