(* 2012 RunOrg *)

open Ohm
open BatPervasives

type status_event = [`IsSelf] IAvatar.id option * IAvatar.t * IInstance.t

let on_update_call,               on_update               = Sig.make (Run.list_iter identity)
let on_upgrade_to_admin_call,     on_upgrade_to_admin     = Sig.make (Run.list_iter identity)
let on_upgrade_to_member_call,    on_upgrade_to_member    = Sig.make (Run.list_iter identity)
let on_downgrade_to_member_call,  on_downgrade_to_member  = Sig.make (Run.list_iter identity)
let on_downgrade_to_contact_call, on_downgrade_to_contact = Sig.make (Run.list_iter identity)
let on_obliterate_call,           on_obliterate           = Sig.make (Run.list_iter identity)
let on_merge_call,                on_merge                = Sig.make (Run.list_iter identity)
let refresh_grant_call,           refresh_grant           = Sig.make (Run.list_iter identity)
