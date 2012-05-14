(* © 2012 RunOrg *)

val on_post_call       : (MItem_types.bot_item, unit O.run) Ohm.Sig.listener
val on_post            : (MItem_types.bot_item, unit O.run) Ohm.Sig.channel
val on_obliterate_call : (IItem.t, unit O.run) Ohm.Sig.listener
val on_obliterate      : (IItem.t, unit O.run) Ohm.Sig.channel
