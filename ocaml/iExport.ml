(* © 2012 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

include Ohm.Id.Phantom

module Assert = struct
  let read = identity 
end

module Deduce = struct

  let make_read_token user item = 
    ICurrentUser.prove "read_export" user [Id.str item]
      
  let from_read_token user item proof =
    if ICurrentUser.is_proof proof "read_export" user [Id.str item] then Some item else None

end
