(* © 2013 RunOrg *)

open Ohm
  
include Id.Phantom
    
module Assert = struct 
  let write  id = id
  let list   id = id
  let admin  id = id
  let bot    id = id
end
