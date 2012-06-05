(* © 2012 RunOrg *)

type 'a t 

val create :
      id:[`Created] IEntity.id
  ->  who:MUpdateInfo.who
  -> ?name:(TextOrAdlib.t option)
  -> ?data:(string * Ohm.Json.t) list
  ->  unit
  ->  unit O.run

val update :
      id:[`Admin] IEntity.id
  ->  who:MUpdateInfo.who
  -> ?name:(TextOrAdlib.t option)
  ->  data:(string * Ohm.Json.t) list
  ->  unit
  ->  unit O.run

val get : 'any IEntity.id -> 'any t option O.run

val data   : [<`View|`Admin|`Bot] t -> (string * Ohm.Json.t) list
val name   : [<`View|`Admin|`Bot] t -> TextOrAdlib.t option

val description : ITemplate.t -> [<`View|`Admin|`Bot] t -> string option

module Signals : sig

  val update : ([`Bot] IEntity.id, unit O.run) Ohm.Sig.channel

end
