(* © 2012 RunOrg *)

open Ohm
open BatPervasives

include Id.Phantom

module Assert = struct
  let write = identity
  let read  = identity
  let admin = identity
  let bot   = identity
end

module Deduce = struct
  let read = identity
end
  

