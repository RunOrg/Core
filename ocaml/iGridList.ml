(* © 2012 RunOrg *)

open Ohm

type 'relation id = [`Config|`Edit|`List|`None] * Id.t
    
let to_string (_,id) = Id.str id
let to_id     (_,id) = id
  
module Assert = struct
  let make ~role ~id = (role,id)
  let can_edit ~id = make ~role:`Edit ~id
  let can_list ~id = make ~role:`List ~id
  let can_config ~id = make ~role:`Config ~id
  let bot id = id
end
  
let make ~id = Assert.make ~role:`None ~id
  
module Deduce = struct
    
  let can_config id = match id with (`Config,_) -> Some id | _ -> None
    
  let can_list id   = match id with (`Config,_) | (`Edit,_) | (`List,_) -> Some id | _ -> None
    
  let can_edit id   = match id with (`Config,_) | (`Edit,_) -> Some id | _ -> None
    
  let list id = id
    
  let make_list_token user (_,id) = 
    ICurrentUser.prove "list" user [Id.str id]      
      
  let from_list_token user (_,id) proof = 
    if ICurrentUser.is_proof proof "list" user [Id.str id] 
    then Some (`List,id) 
    else None
      
end
