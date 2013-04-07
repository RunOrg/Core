(* © 2013 RunOrg *)

val on_update_call     : (IAvatar.t * IInstance.t, unit O.run) Ohm.Sig.listener
val on_update          : (IAvatar.t * IInstance.t, unit O.run) Ohm.Sig.channel
  
val on_obliterate_call : (IAvatar.t * IInstance.t, unit O.run) Ohm.Sig.listener
val on_obliterate      : (IAvatar.t * IInstance.t, unit O.run) Ohm.Sig.channel

val refresh_grant_call : (IAvatar.t, unit O.run) Ohm.Sig.listener
val refresh_grant      : (IAvatar.t, unit O.run) Ohm.Sig.channel
