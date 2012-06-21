(* © 2012 IRunOrg *)

open Ohm

include PreConfig_TemplateId

type 'rel id = t

let decay id = id

let admin   = `Admin
let members = `Admin

module Assert = struct 
  let can_create id = id
end
  
module Deduce = struct
    
  let make_create_token id isin = 
    ICurrentUser.prove "create_with_template" (IIsIn.user isin)
      [ IInstance.to_string (IIsIn.instance isin) ; to_string id ]
      
  let from_create_token id isin proof =
    if ICurrentUser.is_proof proof "create_with_template" (IIsIn.user isin) 
      [ IInstance.to_string (IIsIn.instance isin) ; to_string id ] 
    then Some id 
    else None
      
end
