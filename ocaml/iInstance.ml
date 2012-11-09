(* © 2012 RunOrg *)

open Ohm
open BatPervasives

include Id.Phantom

module Assert = struct

  let created      = identity
  let canInstall   = identity

  let is_contact   = identity
  let is_token     = identity
  let is_admin     = identity

  let create_event = identity

  let upload       = identity
  let rights       = identity
  let bot          = identity

  let see_contacts = identity

end
  
module Deduce = struct

  let can_see_usage     = identity
  let create_can_upload = identity

  let admin_create_group = identity
  let admin_create_forum = identity
  let admin_view_profile = identity

  let upload = identity

  let is_admin = identity

  let see_contacts = identity

  let make_canInstall_token id user = 
    ICurrentUser.prove "can_install" user [Id.str id]
      
  let from_canInstall_token id user proof =
    if ICurrentUser.is_proof proof "can_install" user [Id.str id] 
    then Some id else None

end
