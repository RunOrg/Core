(* © 2012 RunOrg *)

module Payload : sig

  type t = 
      MembershipMass of [ `Invite | `Add | `Remove | `Validate | `Create ] * IEntity.t * int
    | MembershipAdmin of [ `Invite | `Add | `Remove | `Validate ] * IEntity.t * IAvatar.t
    | MembershipUser of bool * IEntity.t
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
