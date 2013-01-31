(* © 2013 RunOrg *)

val on_delete_call : (IGroup.t * IAvatarSet.t, unit O.run) Ohm.Sig.listener 
val on_delete      : (IGroup.t * IAvatarSet.t, unit O.run) Ohm.Sig.channel     

val on_update_call : (IGroup.t, unit O.run) Ohm.Sig.listener
val on_update      : (IGroup.t, unit O.run) Ohm.Sig.channel

val on_bind_group_call : (   IInstance.t
                           * IGroup.t
		           * IAvatarSet.t
                           * ITemplate.Group.t
			   * [`IsSelf] IAvatar.id, unit O.run) Ohm.Sig.listener
val on_bind_group      : (   IInstance.t
                           * IGroup.t
		           * IAvatarSet.t
                           * ITemplate.Group.t
			   * [`IsSelf] IAvatar.id, unit O.run) Ohm.Sig.channel

