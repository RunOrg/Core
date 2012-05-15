(* © 2012 IRunOrg *)

open Ohm

include Id.Phantom
  
module Assert = struct
  let is_admin  id = id
end

module Deduce = struct
end

let prove what who args = 
  ConfigKey.prove (what :: Id.str who :: args) 

let is_proof proof what who args =
  ConfigKey.is_proof proof (what :: Id.str who :: args) 
