(* © 2013 RunOrg *)

open Ohm
  
module Plugin = Id.Phantom
module Solve  = Id.Phantom
module Action = Id.Phantom
module Wave   = Id.Phantom

include Id.Phantom

module Assert = struct
  let bot           id = id
  let can_read      id = id   
  let can_send      id = id
end   

