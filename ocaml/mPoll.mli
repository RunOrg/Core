(* © 2013 RunOrg *)

type details = <
  questions : TextOrAdlib.t list ;
  multiple  : bool
>

type stats = <
  answers : (TextOrAdlib.t * int) list ;
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
  val get : [`IsSelf] IAvatar.id -> [`Read] IPoll.id -> int list O.run
  val set : [`IsSelf] IAvatar.id -> [`Answer] IPoll.id -> int list -> unit O.run

  val get_all : 
       ?start:IAvatar.t 
    -> count:int 
    -> [`Read] IPoll.id 
    -> int 
    -> (#O.ctx, IAvatar.t list * IAvatar.t option) Ohm.Run.t

end

val delete_now : [`Bot] IPoll.id -> unit O.run
