(* © 2012 RunOrg *)

type status_event = [`IsSelf] IAvatar.id option * IAvatar.t * IInstance.t

val on_update_call          : (IAvatar.t * IInstance.t, unit O.run) Ohm.Sig.listener
val on_update               : (IAvatar.t * IInstance.t, unit O.run) Ohm.Sig.channel
  
val on_upgrade_to_admin_call : (status_event, unit O.run) Ohm.Sig.listener
val on_upgrade_to_admin      : (status_event, unit O.run) Ohm.Sig.channel

val on_upgrade_to_member_call : (status_event, unit O.run) Ohm.Sig.listener
val on_upgrade_to_member      : (status_event, unit O.run) Ohm.Sig.channel

val on_downgrade_to_member_call : (status_event, unit O.run) Ohm.Sig.listener
val on_downgrade_to_member      : (status_event, unit O.run) Ohm.Sig.channel

val on_downgrade_to_contact_call : (status_event, unit O.run) Ohm.Sig.listener
val on_downgrade_to_contact     : (status_event, unit O.run) Ohm.Sig.channel

val on_obliterate_call : (IAvatar.t * IInstance.t, unit O.run) Ohm.Sig.listener
val on_obliterate      : (IAvatar.t * IInstance.t, unit O.run) Ohm.Sig.channel

val on_merge_call : (IAvatar.t * IAvatar.t, unit O.run) Ohm.Sig.listener
val on_merge      : (IAvatar.t * IAvatar.t, unit O.run) Ohm.Sig.channel 
