(* © 2012 MRunOrg *)

type 'a t 

val create :
      id:[`Created] IEntity.id
  ->  who:MUpdateInfo.who
  -> ?name:(Ohm.I18n.text option)
  -> ?data:(string * Json_type.t) list
  ->  fields:MEntityFields.Diff.t list
  ->  info:MEntityInfo.Diff.t list
  ->  unit
  ->  unit O.run

val upgrade : 
      id:[`Bot] IEntity.id
  -> ?name:(Ohm.I18n.text option)
  -> ?data:(string * Json_type.t) list
  -> ?fields:MEntityFields.Diff.t list
  -> ?info:MEntityInfo.Diff.t list
  ->  unit
  ->  unit O.run

val update :
      id:[`Admin] IEntity.id
  ->  who:MUpdateInfo.who
  -> ?name:(Ohm.I18n.text option)
  ->  data:(string * Json_type.t) list
  ->  unit
  ->  unit O.run

val recover : 
     id:IEntity.t
  -> name:[ `label of string | `text of string ] option
  -> data:(string * Json_type.t) list 
  -> fields:MEntityFields.t
  -> info:MEntityInfo.t
  -> unit
  -> unit O.run

val get : 'any IEntity.id -> 'any t option O.run

val data   : [<`View|`Admin|`Bot] t -> (string * Json_type.t) list
val name   : [<`View|`Admin|`Bot] t -> Ohm.I18n.text option
val info   : 'any t -> MEntityInfo.t
val fields : 'any t -> MEntityFields.t

val description :  [<`View|`Admin|`Bot] t -> string option

module Signals : sig

  val update : ([`Bot] IEntity.id, unit O.run) Ohm.Sig.channel

end
