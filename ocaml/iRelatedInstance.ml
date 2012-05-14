(* © 2012 RunOrg *)

open Ohm
open BatPervasives

include Id.Phantom

module Assert = struct
  let view  = identity
  let admin = identity 
  let own   = identity
end
  
module Deduce = struct
end
