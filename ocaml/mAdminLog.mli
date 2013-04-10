(* © 2013 RunOrg *)

module Payload : sig

  type t = 
      MembershipMass of [ `Invite | `Add | `Remove | `Validate | `Create ] * 
	  [ `Event of IEvent.t | `Group of IGroup.t ] * int
    | MembershipAdmin of [ `Invite | `Add | `Remove | `Validate ] * 
	[ `Event of IEvent.t | `Group of IGroup.t ] * IAvatar.t
    | MembershipUser of bool * [ `Event of IEvent.t | `Group of IGroup.t ] 
    | InstanceCreate 
    | LoginManual 
    | LoginSignup
    | LoginWithNotify of INotif.Plugin.t
    | LoginWithReset
    | UserConfirm
    | ItemCreate of IItem.t
    | CommentCreate of IComment.t 
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
