(* © 2012 MRunOrg *)

module Count : Ohm.Fmt.FMT with type t = < unread : int ; pending : int ; total : int >
val count : 'any ICurrentUser.id -> Count.t O.run

module ChannelType : Ohm.Fmt.FMT with type t = 
  [ `myMembership 
  | `message
  | `likeItem     
  | `commentItem 
  | `welcome      
  | `subscription 
  | `event
  | `forum
  | `album
  | `group
  | `poll
  | `course
  | `pending
  | `item
  | `networkInvite
  | `digest
  | `chatReq
  ]

module Channel : Ohm.Fmt.FMT with type t = 
  [ `myMembership 
  | `publishItem    of IItem.t
  | `likeItem       of IItem.t
  | `commentItem    of IItem.t
  | `welcome       
  | `joinEntity     of IEntity.t * MEntityKind.t
  | `joinPending    of IEntity.t
  | `networkConnect of IRelatedInstance.t
  | `networkInvite  of IRelatedInstance.t
  | `chatReq        of [ `entity of IEntity.t | `instance of IInstance.t ]
  ]

val type_of_channel : Channel.t -> ChannelType.t

module PublishItem : Ohm.Fmt.FMT with type t = <
  who : IAvatar.t ;
  what : IItem.t
>

module JoinPending : Ohm.Fmt.FMT with type t = <
  who : IAvatar.t ;
  what : IEntity.t
>

module MyMembership : Ohm.Fmt.FMT with type t = < 
  who : IAvatar.t ; 
  what : [ `toAdmin    
	 | `toMember ]
>    

module LikeItem : Ohm.Fmt.FMT with type t = < 
  who : IAvatar.t ; 
  on  : IItem.t
>


module CommentItem : Ohm.Fmt.FMT with type t = <
  who  : IAvatar.t ;
  on   : IItem.t ; 
  what : IComment.t 
>

module JoinEntity : Ohm.Fmt.FMT with type t = <
  who  : IAvatar.t ;
  what : IEntity.t ;
  kind : MEntityKind.t ; 
  how  : [ `invite ]
>

module NetworkInvite : Ohm.Fmt.FMT with type t = <
  who       : IAvatar.t ;
  text      : string ;
  contact   : IRelatedInstance.t ;
  contacted : string
>

module NetworkConnect : Ohm.Fmt.FMT with type t = <
  contact   : IRelatedInstance.t 
>

module ChatRequest : Ohm.Fmt.FMT with type t = <
  who   : IAvatar.t ;
  topic : string ;
  where : [ `entity of IEntity.t | `instance of IInstance.t ]
>

module Welcome : Ohm.Fmt.FMT with type t = <
  who     : IAvatar.t ;
  from    : IInstance.t ;
  context : [ `becomeMember 
	    | `inviteGroup  of IEntity.t
	    | `inviteEvent  of IEntity.t ]
>

module Payload : Ohm.Fmt.FMT with type t =
  [ `myMembership   of MyMembership.t 
  | `publishItem    of PublishItem.t
  | `likeItem       of LikeItem.t
  | `commentItem    of CommentItem.t
  | `welcome        of Welcome.t
  | `joinEntity     of JoinEntity.t
  | `joinPending    of JoinPending.t
  | `networkInvite  of NetworkInvite.t
  | `networkConnect of NetworkConnect.t
  | `chatReq        of ChatRequest.t
  ]

include Ohm.Fmt.FMT with type t = <
  t    : MType.t ;
  who  : IUser.t ;
  chan : Channel.t ;
  inst : IInstance.t option ;
  what : Payload.t list ;
  time : float ;
  read : bool ;
  sent : bool
>

module Signals : sig

  val on_send : (< 
    id   : [`Send] INotification.id ; 
    who  : IUser.t ; 
    inst : IInstance.t option ; 
    what : Payload.t 
  >, unit O.run) Ohm.Sig.channel 

end

val fetch : [`IsSelf] IUser.id -> int -> (bool * [`Read] INotification.id * t) list O.run

val bot_get : [`Bot] INotification.id -> t option O.run

val instance : 'any INotification.id -> IInstance.t option O.run

val from_link : 
     string 
  -> [`Unsafe] ICurrentUser.id option 
  -> INotification.t
  -> [`connected of [`Unsafe] ICurrentUser.id * t
     |`not_connected of t
     |`missing ] O.run
