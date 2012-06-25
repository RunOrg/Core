(* © 2012 IRunOrg *)

include Ohm.Id.PHANTOM
  
module Assert : sig
  val created      : 'any id -> [`Created] id
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

  val is_admin : [`Created] id -> [`IsAdmin] id
    
  val upload : [<`IsAdmin|`IsToken] id -> [`Upload] id

  val admin_view_members : [`IsAdmin] id -> [`ViewMembers] id
  val admin_upload       : [`IsAdmin] id -> [`Upload] id
  val admin_edit         : [`IsAdmin] id -> [`Update] id
  val admin_create_event : [`IsAdmin] id -> [`CreateEvent] id
  val admin_create_group : [`IsAdmin] id -> [`CreateGroup] id
  val admin_create_forum : [`IsAdmin] id -> [`CreateForum] id
  val admin_create_album : [`IsAdmin] id -> [`CreateAlbum] id
  val admin_create_poll  : [`IsAdmin] id -> [`CreatePoll] id
  val admin_create_subscription : [`IsAdmin] id -> [`CreateSubscription] id
  val admin_create_course : [`IsAdmin] id -> [`CreateCourse] id
  val admin_view_profile : [`IsAdmin] id -> [`ViewProfile] id

  val see_contacts : [<`IsAdmin|`Rights] id -> [`ViewContacts] id

  val make_createEvent_token : [`CreateEvent] id -> [`Unsafe] ICurrentUser.id -> string
  val from_createEvent_token : 'any id -> [`Unsafe] ICurrentUser.id -> string -> [`CreateEvent] id option 
    
  val make_seeContacts_token : [`ViewContacts] id -> [`Unsafe] ICurrentUser.id -> string
  val from_seeContacts_token : 'any id -> [`Unsafe] ICurrentUser.id -> string -> [`ViewContacts] id option     
end
