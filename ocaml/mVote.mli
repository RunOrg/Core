(* © 2012 RunOrg *)

module Owner : Ohm.Fmt.FMT with type t = 
  [ `entity of IEntity.t ] 

type 'relation t 
type 'relation vote = 'relation t

module Can : sig 
  val read  : 'any t -> [`Read] t option O.run
  val vote  : 'any t -> [`Vote] t option O.run
  val admin : 'any t -> [`Admin] t option O.run
end

module Config : sig

  type t = <
    closed_on : float option ;
    opened_on : float option ;
  > ;;
 
  val create : ?closed:float -> ?opened:float -> unit -> t 

  val get   : 'any vote -> t
  val set   : [`Admin] vote -> t -> unit O.run
  val close : [`Admin] vote -> unit O.run

end

module Question : sig

  type t = <
    question : Ohm.I18n.text ;
    answers  : Ohm.I18n.text list ;
    multiple : bool 
  > 

  val create : 
       multiple:bool
    -> question:Ohm.I18n.text
    -> answers:Ohm.I18n.text list
    -> t 

  val get : [<`Read|`Vote|`Admin] vote -> t 

end

module Stats : sig

  type t = <
    count   : int ;
    votes   : (Ohm.I18n.text * int) list 
  >

  val get_short : [<`Read|`Vote|`Admin] vote -> t O.run 
  val get_long  : [<`Read|`Vote|`Admin] vote -> (IAvatar.t * int list) list O.run 

end

module Mine : sig

  val set : [`Vote] vote -> [`IsSelf] IAvatar.id -> int list -> bool O.run

  val get : [`Vote] vote -> [`IsSelf] IAvatar.id -> int list option O.run

end

module Signals : sig

  val on_create : ([`Unknown] vote, unit O.run) Ohm.Sig.channel 

end

module Get : sig
  val id        : 'any vote -> 'any IVote.id
  val creator   : [<`Read|`Vote|`Admin] vote -> IAvatar.t 
  val created   : [<`Read|`Vote|`Admin] vote -> float
  val anonymous : [<`Read|`Vote|`Admin] vote -> bool 
end

val create : 
     ctx:'a # MAccess.context 
  -> owner:[`entity of [`Admin] MEntity.t] 
  -> config:Config.t
  -> question:Question.t 
  -> anonymous:bool
  -> unit O.run

val try_get : 'a # MAccess.context -> 'any IVote.id -> 'any vote option O.run

val by_owner : 'a # MAccess.context -> [`entity of 'any MEntity.t] -> [`Unknown] vote list O.run
