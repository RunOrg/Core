(* © 2012 RunOrg *)

module MiniJoin : Ohm.Fmt.FMT with type t = <
  a  : IAvatar.t ;    
  e  : IEntity.t ;
  s  : [ `invited   of IAvatar.t
       | `denied    
       | `added     of IAvatar.t option
       | `removed   of IAvatar.t option 
       | `requested ] ; 
  t  : float ;
>

type t = [ `item of IItem.t
	 | `join of MiniJoin.t
	 ]

module List : sig

  val by_instance :
       instance:IInstance.t
    -> ctx: 'a # MAccess.context
    -> not_avatar: IAvatar.t option 
    -> float option 
    -> (t list * float option) O.run

  val by_avatar :
       avatar:IAvatar.t
    -> ctx: 'a # MAccess.context
    -> float option
    -> (t list * float option) O.run

end

module Login : Ohm.Fmt.FMT with type t = 
  [ `Notification of IInstance.t * MNotification.ChannelType.t * IUser.t
  | `Login        of IUser.t ] 

module FromLogin : sig

  val create : Login.t -> unit O.run

end

module Backdoor : sig

  type t =
    [ `item of IItem.t
    | `join of MiniJoin.t
    | `createInstance of IInstance.t 
    | `networkConnect of IRelatedInstance.t
    | `login of Login.t ]

  val since : float -> (float * t) list O.run 

  val stats : day:float -> <
    active_instances_30 : int ;
    active_instances_7  : int ;
    active_instances    : int ;
    active_users_30 : int ;
    active_users_7  : int ;
    active_users    : int ;
    logins_30 : int ;
    logins_7  : int ;
    logins    : int ;
    messages_30 : int ;
    messages_7  : int ;
    messages    : int
  > O.run

end
