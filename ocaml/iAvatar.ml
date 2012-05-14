(* © 2012 IRunOrg *)

open Ohm

include Id.Phantom

module Assert = struct 
  let is_self id = id
  let bot     id = id
end
  
module Deduce = struct
    
  let make_token user id = 
    ConfigKey.prove ["owns_avatar" ; ICurrentUser.to_string user ; Id.str id]
      
  let from_token user id proof =
    if ConfigKey.is_proof proof  ["owns_avatar" ; ICurrentUser.to_string user ; Id.str id] then Some id else None
      
end
