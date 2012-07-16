(* © 2012 RunOrg *)

open Ohm
  
include Id.Phantom

module Assert = struct
  let bot           id = id
  let can_read      id = id   
  let can_send      id = id
end   

module Deduce = struct
end
