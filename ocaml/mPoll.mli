(* © 2012 RunOrg *)

type details = <
  questions : Ohm.I18n.text list ;
  multiple  : bool
>

type stats = <
  answers : (Ohm.I18n.text * int) list ;
  total : int ;
>

type 'relation t

val create : details -> [`Created] IPoll.id O.run

val get : 'relation IPoll.id -> 'relation t option O.run

module Get : sig

  val details : [<`Answer|`Read] t -> details
  val stats   : [<`Answer|`Read] t -> stats    

end

module Answer : sig

  val answered : 'any IAvatar.id -> [`Read] IPoll.id -> bool O.run
  val get_all : count:int -> [`Read] IPoll.id -> int -> IAvatar.t list O.run
  val get : [`IsSelf] IAvatar.id -> [`Read] IPoll.id -> int list O.run
  val set : [`IsSelf] IAvatar.id -> [`Answer] IPoll.id -> int list -> unit O.run

end

val delete_now : [`Bot] IPoll.id -> unit O.run
