(* © 2012 RunOrg *)

module Signals : sig

  val on_send : (IUser.t * float * IMessage.t * IItem.t, unit O.run) Ohm.Sig.channel

end

module Envelope : Ohm.Fmt.FMT with type t = < 
  t : MType.t ;
  instance : IInstance.t ; 
  last : float ;
  last_by : IAvatar.t ; 
  prev_by : IAvatar.t option ;
  people : int ;
  title : string 
>

val send_next : bool O.run

val create :
     instance:IInstance.t
  -> who:[ `IsSelf ] IAvatar.id 
  -> invited:IAvatar.t list 
  -> title:string 
  -> IMessage.t O.run

val create_and_post :
     ctx : 'any #MAccess.context
  -> invited:IAvatar.t list
  -> title:string
  -> post:string
  -> IMessage.t O.run

val invite : 
     ctx:'a #MAccess.context
  -> invited:IAvatar.t list
  -> 'b IMessage.id
  -> unit O.run

val invite_group : 
     ctx:'a #MAccess.context
  -> invited:[<`Admin|`Write|`Bot|`List] IGroup.id
  -> access:MAccess.State.t
  -> 'b IMessage.id
  -> unit O.run

val get_instance : 'a IMessage.id -> IInstance.t option O.run

val find_feed :
      ctx:'a #MAccess.context 
  -> 'b IMessage.id 
  -> [`Unknown] MFeed.t O.run

val get_title :
     ctx:'a #MAccess.context 
  -> 'b IMessage.id 
  -> [> `Forbidden | `None | `Some of string ] O.run

val get_participants : 
      ctx: 'a #MAccess.context
  -> 'b IMessage.id
  -> [ `Forbidden | `List of IAvatar.t list] O.run

val get_groups : 
     ctx: 'a #MAccess.context
  -> 'b IMessage.id
  -> [ `Forbidden | `List of (IGroup.t * MAccess.State.t) list ] O.run

val get_participants_forced : 
     [`Rights] IInstance.id 
  -> 'a IMessage.id
  -> (IAvatar.t list * ((IGroup.t * MAccess.State.t) list)) O.run 

val mark_as_read : [`IsSelf] IUser.id -> 'b IMessage.id -> unit O.run

val in_message : MAccess.in_message 

val count : [`IsSelf] IUser.id -> (IInstance.t * int) list O.run

val total_count : [`IsSelf] IUser.id -> int O.run

type message_details = < 
  id       : [ `Read ] IMessage.id; 
  last     : float;
  last_by  : IAvatar.t; 
  prev_by  : IAvatar.t option ;
  people   : int ;
  read     : bool ; 
  title    : string ;
  instance : IInstance.t
>

val bot_get_details : [`Bot] IMessage.id -> message_details option O.run

val get_by_instance :
     ?before:float 
  ->  'a IUser.id 
  ->  'b IInstance.id 
  ->  int 
  ->  message_details list O.run
