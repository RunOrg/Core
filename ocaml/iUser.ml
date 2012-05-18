(* © 2012 IRunOrg *)

open Ohm
open BatPervasives

include Id.Phantom

module Assert = struct 
  let is_self    = identity
  let created    = identity
  let updated    = identity 
  let is_new  id = ICurrentUser.Assert.is_new (ICurrentUser.of_id id)
  let is_old  id = ICurrentUser.Assert.is_old (ICurrentUser.of_id id)
  let bot        = identity
end
  
module Deduce = struct
        
  (* -- *)
    
  let make_new_session_token id = 
    ConfigKey.prove ["new-session" ; ICurrentUser.to_string id]
      
  let make_old_session_token id = 
    ConfigKey.prove ["session" ; ICurrentUser.to_string id ]

  let from_session_token proof id =
    if ConfigKey.is_proof proof ["session" ; Id.str id] 
    then `Old (Assert.is_old id) else 
      if ConfigKey.is_proof proof ["new-session" ; Id.str id] 
      then `New (Assert.is_new id) else `None

  (* -- *)

  let make_confirm_token id = 
    ConfigKey.prove ["confirm" ; ICurrentUser.to_string id]
      
  let from_confirm_token proof id =
    if ConfigKey.is_proof proof  ["confirm" ; Id.str id] 
    then Some (Assert.is_old id) else None

  let old_can_confirm id = ICurrentUser.to_id id
      
  (* -- *)

  let make_unsub_token id = 
    ConfigKey.prove ["unsubscribe" ; Id.str id]
      
  let from_unsub_token proof id =
    if ConfigKey.is_proof proof  ["unsubscribe" ; Id.str id] 
    then Some id else None

  (* -- *)

  let can_block     id = ICurrentUser.to_id id 
  let can_edit      id = ICurrentUser.to_id id
  let can_view      id = ICurrentUser.to_id id
  let can_view_inst id = ICurrentUser.to_id id 
  let is_anyone     id = ICurrentUser.to_id id

  (* -- *)
  
  let current_is_self id = ICurrentUser.to_id id
  let self_is_current id = Assert.is_old id   

  (* -- *)

  let view      = identity  
  let view_inst = identity 

end
