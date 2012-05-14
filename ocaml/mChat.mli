(* © 2012 RunOrg *)

module Line : sig

  type text = {
    text_author   : IAvatar.t ;
    text_contents : string ;
    text_time     : float
  }
      
  module Payload : Ohm.Fmt.FMT with type t = 
    [ `text of text ]

  include Ohm.Fmt.FMT 

  val payload : t -> Payload.t

end

module Feed : sig

  val count : [<`View|`Post] IChat.Room.id -> int O.run

  val list : 
       ?start:IChat.Line.t
    -> ?reverse:bool
    ->  count:int
    ->  [<`View|`Post] IChat.Room.id
    ->  (Line.t list * IChat.Line.t option) O.run
    
end

module Room : sig

  module Signals : sig
    val on_appear : (IChat.Room.t, unit O.run) Ohm.Sig.channel
    val on_create : ([`Created] IChat.Room.id * [`Write] MFeed.t, unit O.run) Ohm.Sig.channel
  end

  val recent : 
       [`Write] MFeed.t
    -> ([`Post] IChat.Room.id * [`View] IChat.Room.id option) O.run

  val ensure : 'any IChat.Room.id -> unit O.run
   
  val active : [`View] IChat.Room.id -> [`Post] IChat.Room.id option O.run

  val readable : 'any IChat.Room.id -> [`Read] IFeed.id -> [`View] IChat.Room.id option O.run

  val all_active : 'any IInstance.id -> IFeed.t list O.run

end

module Participant : sig

  val count : [<`View|`Post] IChat.Room.id -> int O.run

  val list :
       ?start:IAvatar.t
    ->  count:int
    ->  [<`View|`Post] IChat.Room.id
    ->  (IAvatar.t list * IAvatar.t option) O.run

end

val post : 
     [`Post] IChat.Room.id 
  -> Line.Payload.t
  -> [`IsSelf] IAvatar.id
  -> unit O.run


val url    : 
  [<`View|`Post] IChat.Room.id -> [`IsSelf] IAvatar.id -> string option O.run

val delete_now : [`Bot] IChat.Room.id -> unit O.run
