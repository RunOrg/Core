(* © 2012 RunOrg *)

val on_update_call : ([`Bot] IEntity.id, unit O.run) Ohm.Sig.listener
val on_update      : ([`Bot] IEntity.id, unit O.run) Ohm.Sig.channel

val on_bind_group_call : (   IInstance.t
                           * [`Created] IEntity.id
		           * [`Bot] IGroup.id
                           * ITemplate.t
			   * [`IsSelf] IAvatar.id, unit O.run) Ohm.Sig.listener
val on_bind_group      : (   IInstance.t
                           * [`Created] IEntity.id
		           * [`Bot] IGroup.id
                           * ITemplate.t
			   * [`IsSelf] IAvatar.id, unit O.run) Ohm.Sig.channel

