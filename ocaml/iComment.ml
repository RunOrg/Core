(* © 2012 IRunOrg *)

open Ohm

include Id.Phantom
  
module Assert = struct 
  let created     id = id
  let read        id = id
  let liked       id = id
end
  
module Deduce = struct
    
  let read_can_like  id = id
    
  let make_like_token user comment = 
    ICurrentUser.prove "like_comment" user [Id.str comment]
      
  let from_like_token user comment proof =
    if ICurrentUser.is_proof proof  "like_comment" user [Id.str comment]
    then Some comment else None
      
end

