(* © 2012 RunOrg *)

module Payload : sig

  type t = 
    | MembershipInvite of IEntity.t * IAvatar.t * int
    | MembershipAdd of IEntity.t * IAvatar.t * int
    | MembershipInviteAccept of IEntity.t * IAvatar.t 
    | MembershipInviteDecline of IEntity.t * IAvatar.t 
    | MembershipRequest of IEntity.t * IAvatar.t
    | MembershipLeave of IEntity.t * IAvatar.t 
    | MembershipValidate of IEntity.t * IAvatar.t
    | InstanceCreate 
    | LoginManual 
    | LoginSignup
    | LoginWithNotify of MNotifyChannel.t
    | LoginWithReset
    | NotifyClickMail of MNotifyChannel.t 
    | NotifyClickSite of MNotifyChannel.t
    | UserConfirm
    | ItemCreate of IItem.t
    | CommentCreate of IComment.t 
    | EntityCreateGroup of IEntity.t 
    | EntityCreateEvent of IEntity.t 
    | EntityCreateForum of IEntity.t 
    | BroadcastPublish of IBroadcast.t

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
