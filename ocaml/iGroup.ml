(* © 2013 RunOrg *)

open Ohm
open BatPervasives
  
include Id.Phantom

let admin = "admin"
let members = "members"

module Assert = struct 
  let admin = identity
  let view  = identity
end

module Deduce = struct
end
