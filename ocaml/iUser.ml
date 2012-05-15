(* © 2012 IRunOrg *)

open Ohm
open BatPervasives

include Id.Phantom

module Assert = struct 
  let is_self     id = id
  let can_confirm id = id
  let can_view    id = id
  let is_current  id = ICurrentUser.of_id id
  let updated     id = id
  let created     id = id
  let beta        id = id
  let bot         id = id
end
  
module Deduce = struct
    
  let current_is_self id = ICurrentUser.to_id id
    
  let make_login_token id = 
    ConfigKey.prove ["login" ; Id.str id]
      
  let from_login_token proof id =
    if ConfigKey.is_proof proof  ["login" ; Id.str id] 
    then Some (Assert.is_current id) else None
      
  let make_block_token id = 
    ConfigKey.prove ["block" ; Id.str id]
      
  let from_block_token proof id =
    if ConfigKey.is_proof proof  ["block" ; Id.str id] 
    then Some id else None

  let make_confirm_token id = 
    ConfigKey.prove ["confirm" ; Id.str id]
      
  let from_confirm_token proof id =
    if ConfigKey.is_proof proof  ["confirm" ; Id.str id] 
    then Some id else None
      
  let block = identity 

  let self_can_login     id = id
  let current_can_login  id = ICurrentUser.to_id id
  let self_can_confirm   id = id
  let self_can_edit      id = id
  let self_can_view      id = id
  let self_can_view_inst id = id
  let admin_can_edit   _ id = id
  let admin_can_view   _ id = id      
  let edit_can_view      id = id
  let current_is_anyone  id = ICurrentUser.to_id id
  let current_can_view   id = ICurrentUser.to_id id
  let self_is_current    id = Assert.is_current id
  let can_view           id =  id

end
