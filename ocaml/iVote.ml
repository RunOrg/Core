(* © 2012 RunOrg *)

open Ohm
open BatPervasives

include Id.Phantom

module Assert = struct
  let read = identity
  let vote = identity
  let admin = identity
end
  
module Deduce = struct
end
