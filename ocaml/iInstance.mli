(* © 2013 RunOrg *)

include Ohm.Id.PHANTOM
  
module Assert : sig

  val created      : 'any id -> [`Created] id
  val canInstall   : 'any id -> [`CanInstall] id

  val is_contact   : 'any id -> [`IsContact] id
  val is_token     : 'any id -> [`IsToken] id
  val is_admin     : 'any id -> [`IsAdmin] id

  val create_event : 'any id -> [`CreateEvent] id      

  val upload       : 'any id -> [`Upload] id
  val rights       : 'any id -> [`Rights] id
  val bot          : 'any id -> [`Bot] id

  val see_contacts : 'any id -> [`ViewContacts] id

end
  
module Deduce : sig

  val create_can_upload : [`Created] id -> [`Upload] id

  val can_see_usage : [<`IsAdmin|`Upload] id -> [`SeeUsage] id

  val token_see_contacts : [<`IsToken|`IsAdmin] id -> [`ViewContacts] id 

  val is_admin : [`Created] id -> [`IsAdmin] id
    
  val upload : [<`IsAdmin|`IsToken] id -> [`Upload] id

  val admin_create_group : [`IsAdmin] id -> [`CreateGroup] id
  val admin_create_forum : [`IsAdmin] id -> [`CreateForum] id
  val admin_view_profile : [`IsAdmin] id -> [`ViewProfile] id

  val see_contacts : [<`IsAdmin|`Rights|`Bot] id -> [`ViewContacts] id

  val make_canInstall_token : [`CanInstall] id -> 'any ICurrentUser.id -> string
  val from_canInstall_token : 'any id -> 'a ICurrentUser.id -> string -> [`CanInstall] id option     

end
