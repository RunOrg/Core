(* © 2012 IRunOrg *)

open Ohm

include Id.Phantom
  
module Assert = struct
  let is_admin  id = id
  let is_safe   id = id     
  let is_unsafe id = id
end

module Deduce = struct
  let is_safe id  = id
  let is_unsafe id = id
end

let prove what who args = 
  ConfigKey.prove (what :: Id.str who :: args) 

let is_proof proof what who args =
  ConfigKey.is_proof proof (what :: Id.str who :: args) 
