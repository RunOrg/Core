(* © 2012 IRunOrg *)

open Ohm
open BatPervasives

include Id.Phantom

module Assert = struct
  let created              id = id
  let is_contact           id = id
  let is_token             id = id
  let is_admin             id = id
  let bot                  id = id
  let create_local         id = id
  let upload               id = id
  let rights               id = id
  let see_contacts = identity
end
  
module Deduce = struct

  let can_see_usage id = id      
  let create_can_upload    id = id

  let admin_upload id = id
  let admin_edit   id = id
  let admin_view_members id = id
  let admin_create_event id = id
  let admin_create_group id = id
  let admin_create_forum id = id
  let admin_create_poll  id = id
  let admin_create_album id = id
  let admin_create_subscription id = id
  let admin_create_course id = id
  let admin_view_profile id = id

  let is_admin = identity

  let see_contacts = identity

  let make_createEvent_token id user = 
    ICurrentUser.prove "create_event" user [Id.str id]
      
  let from_createEvent_token id user proof =
    if ICurrentUser.is_proof proof "create_event" user [Id.str id] 
    then Some id else None
      
  let make_seeContacts_token id user = 
    ICurrentUser.prove "see_contacts" user [Id.str id]
      
  let from_seeContacts_token id user proof =
    if ICurrentUser.is_proof proof "see_contacts" user [Id.str id] 
    then Some id else None

end
