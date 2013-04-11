(* © 2013 RunOrg *)

include Ohm.Id.PHANTOM
  
module Assert : sig
  val is_self     : 'unknown id -> [`IsSelf] id
  val created     : 'unknown id -> [`Created] id
  val updated     : 'unknown id -> [`Updated] id
  val bot         : 'unknown id -> [`Bot] id
  val is_new      : 'unknown id -> [`New] ICurrentUser.id 
  val is_old      : 'unknown id -> [`Old] ICurrentUser.id
  val confirm     : 'unknown id -> [`Confirm] id
end
  
module Deduce : sig
    
  (* Allowing both new and old user accounts to login, but segregate which is which. *)
    
  val make_new_session_token : [`New] ICurrentUser.id -> string
  val make_old_session_token : [`Old] ICurrentUser.id -> string
  val from_session_token     : string -> 'unknown id -> [ `None 
							| `Old of [`Old] ICurrentUser.id 
							| `New of [`New] ICurrentUser.id 
							] 

  (* The confirmation sequence. *)

  val make_confirm_token   : [`New] ICurrentUser.id -> string
  val from_confirm_token   : string -> 'unknown id -> [`Old] ICurrentUser.id option 

  val old_can_confirm      : [`Old] ICurrentUser.id -> [`Confirm] id

  (* What the user can always do. *)

  val can_block     : 'any ICurrentUser.id -> [`Block] id
  val can_edit      : 'any ICurrentUser.id -> [`Edit] id
  val can_view      : 'any ICurrentUser.id -> [`View] id
  val can_view_inst : 'any ICurrentUser.id -> [`ViewInstances] id
  val is_anyone     : 'any ICurrentUser.id -> t

  (* What the confirmed current user can do. *)

  val self_is_current : [`IsSelf] id -> [`Old] ICurrentUser.id     
  val current_is_self : [`Old] ICurrentUser.id -> [`IsSelf] id  

  (* What the self user can do. *)  

  val view      : [<`Bot|`IsSelf|`Edit] id -> [`View] id
  val view_inst : [<`Bot|`IsSelf|`Edit] id -> [`ViewInstances] id
  val unsubscribe : [`IsSelf] id -> [`Unsubscribe] id

end
