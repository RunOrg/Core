(* © 2013 RunOrg *)

val on_bind_inboxLine_call : (IGroup.t, unit O.run) Ohm.Sig.listener
val on_bind_inboxLine      : (IGroup.t, unit O.run) Ohm.Sig.channel


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

