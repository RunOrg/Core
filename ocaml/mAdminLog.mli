(* © 2012 RunOrg *)

module Payload : sig

  type t = 
      MembershipMass of [ `Invite | `Add | `Remove | `Validate | `Create ] * 
	  [ `Entity of IEntity.t | `Event of IEvent.t | `Group of IGroup.t ] * int
    | MembershipAdmin of [ `Invite | `Add | `Remove | `Validate ] * 
	[ `Entity of IEntity.t | `Event of IEvent.t | `Group of IGroup.t ] * IAvatar.t
    | MembershipUser of bool * [ `Entity of IEntity.t | `Event of IEvent.t | `Group of IGroup.t ] 
    | InstanceCreate 
    | LoginManual 
    | LoginSignup
    | LoginWithNotify of MNotifyChannel.t
    | LoginWithReset
    | UserConfirm
    | ItemCreate of IItem.t
    | CommentCreate of IComment.t 
    | EntityCreate of [ `Forum | `Event | `Group ] * IEntity.t 
    | BroadcastPublish of [ `Post | `Forward ] * IBroadcast.t
    | SendMail

end

module Stats : Ohm.Fmt.FMT with    
  type t = <
    instanceCreate : int ;
    login : < manual : int ; signup : int ; notify : int ; reset : int > ;
    confirm : int ;
    post : < item : int ; comment : int ; broadcast : int ; forward : int > ;
    mail : int ;
    entity : < forum : int ; event : int ; group : int > ;
  >

type t = <
  uid  : IUser.t ;
  iid  : IInstance.t option ;
  what : Payload.t ;
  time : float
>

val log : 
     ?id:Ohm.Id.t
  ->  uid:IUser.t
  -> ?iid:IInstance.t
  -> ?time:float
  -> Payload.t
  -> (#Ohm.CouchDB.ctx,unit) Ohm.Run.t

val stats : int -> (#Ohm.CouchDB.ctx,Stats.t) Ohm.Run.t

val active_users : period:float -> int O.run
val active_instances : period:float -> int O.run
