(* © 2012 RunOrg *)

val on_update_call : ([`Bot] IEntity.id, unit O.run) Ohm.Sig.listener
val on_update      : ([`Bot] IEntity.id, unit O.run) Ohm.Sig.channel

val on_upgrade_call : ([`Bot] IEntity.id * MPreConfig.entity_diffs, unit O.run) Ohm.Sig.listener
val on_upgrade      : ([`Bot] IEntity.id * MPreConfig.entity_diffs, unit O.run) Ohm.Sig.channel

val on_bind_group_call : (   IInstance.t
                           * [`Created] IEntity.id
		           * [`Bot] IGroup.id
			   * bool
                           * MPreConfig.entity_diffs
			   * [`IsSelf] IAvatar.id option, unit O.run) Ohm.Sig.listener
val on_bind_group      : (   IInstance.t
                           * [`Created] IEntity.id
		           * [`Bot] IGroup.id
			   * bool
                           * MPreConfig.entity_diffs
			   * [`IsSelf] IAvatar.id option, unit O.run) Ohm.Sig.channel

