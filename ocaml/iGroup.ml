(* © 2012 IRunOrg *)

open Ohm
  
include Id.Phantom

type membership = [`Unknown] id -> [`In] id option
    
module Assert = struct 
  let is_in     id = id
  let write     id = id
  let list      id = id
  let admin     id = id
  let bot       id = id
end
