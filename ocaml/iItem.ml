(* © 2012 RunOrg *)

open Ohm

include Id.Phantom

module Assert = struct 
  let created     id = id
  let read        id = id
  let replied     id = id
  let liked       id = id
  let remove      id = id
  let own         id = id
  let bot         id = id
end
  
module Deduce = struct
    
  let read_can_like      id = id
  let read_can_reply     id = id
    
  let own_can_remove     id = id
    
  let created_can_reply  id = id
  let created_can_like   id = id
  let created_can_remove id = id
    
  let make_like_token user item = 
    ICurrentUser.prove "like_item" user [Id.str item]
      
  let from_like_token user item proof =
    if ICurrentUser.is_proof proof "like_item" user [Id.str item] then Some item else None
      
  let make_read_token user item = 
    ICurrentUser.prove "read_item" user [Id.str item]
      
  let from_read_token user item proof =
    if ICurrentUser.is_proof proof "read_item" user [Id.str item] then Some item else None
      
  let make_reply_token user item = 
    ICurrentUser.prove "reply_item" user [Id.str item]
      
  let from_reply_token user item proof =
    if ICurrentUser.is_proof proof "reply_item" user [Id.str item] then Some item else None
      
  let make_remove_token user item = 
    ICurrentUser.prove "remove_item" user [Id.str item]
      
  let from_remove_token user item proof =
    if ICurrentUser.is_proof proof "remove_item" user [Id.str item] then Some item else None
      
end

