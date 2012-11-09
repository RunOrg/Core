(* © 2012 RunOrg *)

open Ohm
open BatPervasives

include Id.Phantom
  
module Assert = struct
  let is_admin = identity
  let is_new   = identity
  let is_old   = identity 
end

module Deduce = struct
end

let prove what who args = 
  ConfigKey.prove (what :: Id.str who :: args) 

let is_proof proof what who args =
  ConfigKey.is_proof proof (what :: Id.str who :: args) 
