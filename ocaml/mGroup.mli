(* © 2012 RunOrg *)

module Signals : sig

  val on_join_admin   : 
    ([`IsSelf] IAvatar.id option * IInstance.t * IAvatar.t, unit O.run) Ohm.Sig.channel

  val on_update : 
    ([`Bot] IGroup.id, unit O.run) Ohm.Sig.channel

  val on_token_grant  :
    ([`IsSelf] IAvatar.id option * IAvatar.t * IGroup.t * bool, unit O.run) Ohm.Sig.channel

  val on_create_list  :
    ( IAvatarGrid.t * IGroup.t * IInstance.t * MGroupColumn.Diff.t list,
      unit O.run ) Ohm.Sig.channel

  val on_upgrade_list :
    ( IAvatarGrid.t * IGroup.t * IInstance.t * MGroupColumn.Diff.t list, 
      unit O.run) Ohm.Sig.channel

end

type 'relation t 

val try_get   :  'any # MAccess.context -> IGroup.t -> [`Unknown] t option O.run
val bot_get   : [`Bot] IGroup.id -> [`Bot] t option O.run
val naked_get :  'any  IGroup.id ->  'any  t option O.run

module Token : sig 

  val get    :    'any  t -> [`contact | `token | `admin] 

end

module Get : sig 

  val id       :                  'any  t -> 'any IGroup.id    
  val is_admin :                  'any  t -> bool
  val instance :                  'any  t -> IInstance.t
  val entity   :                  'any  t -> IEntity.t option
  val manual   :                  'any  t -> bool 
  val list     : [<`Admin|`Write|`List] t -> [`List] IAvatarGrid.id 
  val listedit :         [<`Admin|`Bot] t -> [`Edit] IAvatarGrid.id

  val write_access : 'any t -> MAccess.t O.run

end

module Fields : sig 

  val get      : 'any     t -> MJoinFields.Field.t list 
  val set      : [`Admin] t -> MJoinFields.Field.t list -> unit O.run
  val of_group : 'any IGroup.id -> MJoinFields.Field.t list O.run
  val complete : 'any IGroup.id -> (IGroup.t * ((string * MJoinFields.Field.t) list)) list O.run

end

module Propagate : sig
    
  val add : 'any IGroup.id -> [`Admin] IGroup.id -> 'ctx # MAccess.context -> unit O.run
  val rem : 'any IGroup.id -> [`Admin] IGroup.id -> unit O.run
  val get : [`Admin] IGroup.id -> 'any # MAccess.context -> [`Unknown] t list O.run
  val get_direct : IGroup.t -> IGroup.t list O.run 

  val upgrade : src:[`Bot] IGroup.id -> dest:[`Bot] IGroup.id -> [`add|`remove] -> unit O.run 

end

module Can : sig
    
  val list  : 'any t -> [`List]  t option O.run 
  val write : 'any t -> [`Write] t option O.run 
  val admin : 'any t -> [`Admin] t option O.run 

end


