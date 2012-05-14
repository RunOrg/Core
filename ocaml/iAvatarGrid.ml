(* © 2012 RunOrg *)

open Ohm

include Id.Phantom

module Assert = struct 
  let list id = id
  let edit id = id
end
  
module Deduce = struct
    
  let make_list_token user id = 
    ConfigKey.prove ["grid_list" ; ICurrentUser.to_string user ; Id.str id]
      
  let from_list_token user id proof =
    if ConfigKey.is_proof proof  ["grid_list" ; ICurrentUser.to_string user ; Id.str id]
    then Some id else None
      
end
