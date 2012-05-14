(* © 2012 IRunOrg *)

open Ohm

include Id.Phantom

module Assert = struct 
  let can_create id = id
end
  
module Deduce = struct
    
  let make_create_token id isin = 
    ICurrentUser.prove "create_with_template" (IIsIn.user isin)
      [ IInstance.to_string (IIsIn.instance isin) ; Id.str id ]
      
  let from_create_token id isin proof =
    if ICurrentUser.is_proof proof "create_with_template" (IIsIn.user isin) 
      [ IInstance.to_string (IIsIn.instance isin) ; Id.str id ] 
    then Some id 
    else None
      
end
