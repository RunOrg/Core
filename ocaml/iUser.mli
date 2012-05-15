(* © 2012 IRunOrg *)

include Ohm.Id.PHANTOM
  
module Assert : sig
  val is_self     : 'unknown id -> [`IsSelf] id
  val can_confirm : 'unknown id -> [`Confirm] id
  val can_view    : 'unknown id -> [`View] id
  val is_current  : 'unknown id -> ICurrentUser.t
  val created     : 'unknown id -> [`Created] id
  val updated     : 'unknown id -> [`Updated] id
  val beta        : 'unknown id -> [`Beta] id
  val bot         : 'unknown id -> [`Bot] id
end
  
module Deduce : sig
    
  val current_is_self : 'any ICurrentUser.id -> [`IsSelf] id
    
  val make_login_token   : [`CanLogin] id -> string
  val from_login_token   : string -> 'unknown id -> ICurrentUser.t option

  val make_confirm_token   : [`Confirm] id -> string
  val from_confirm_token   : string -> 'unknown id -> [`Confirm] id option 
    
  val make_block_token   : [`Block] id -> string
  val from_block_token   : string -> 'unknown id -> [`Block] id option 
    
  val self_can_login     : [`IsSelf] id -> [`CanLogin] id
  val current_can_login  : 'any ICurrentUser.id -> [`CanLogin] id 
    
  val block              : [`IsSelf] id -> [`Block] id

  val self_can_confirm   : [`IsSelf] id -> [`Confirm] id  
  val self_can_edit      : [`IsSelf] id -> [`Edit] id
  val self_can_view      : [`IsSelf] id -> [`View] id
  val self_can_view_inst : [`IsSelf] id -> [`ViewInstances] id
    
  val admin_can_edit     : [`Admin] ICurrentUser.id -> 'unknown id -> [`Edit] id
  val admin_can_view     : [`Admin] ICurrentUser.id -> 'unknown id -> [`View] id
    
  val edit_can_view      : [`Edit] id -> [`View] id
   
  val can_view           : [<`Edit|`Confirm|`IsSelf] id -> [`View] id
 
  val current_is_anyone  : 'any ICurrentUser.id -> t
  val current_can_view   : 'any ICurrentUser.id -> [`View] id
    
  val self_is_current    : [`IsSelf] id -> ICurrentUser.t
    
end
