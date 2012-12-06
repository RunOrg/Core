(* © 2012 RunOrg *)

val on_update_call : (IEvent.t, unit O.run) Ohm.Sig.listener
val on_update      : (IEvent.t, unit O.run) Ohm.Sig.channel

val on_bind_group_call : (   IInstance.t
                           * IEvent.t
		           * [`Bot] IGroup.id
                           * ITemplate.Event.t
			   * [`IsSelf] IAvatar.id, unit O.run) Ohm.Sig.listener
val on_bind_group      : (   IInstance.t
                           * IEvent.t
		           * [`Bot] IGroup.id
                           * ITemplate.Event.t
			   * [`IsSelf] IAvatar.id, unit O.run) Ohm.Sig.channel

