(* © 2012 RunOrg *)

module Cache : sig

  type t = [ `Item of IItem.t ]

  val prepare : 'any IUser.id -> unit O.run
  val head : count:int -> 'any IUser.id -> (t list * float option) option O.run
  val rest : count:int -> 'any IUser.id -> float -> (t list * float option) O.run

end
