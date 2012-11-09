(* © 2012 RunOrg *)

open Ohm
  
include Id.Phantom

let members = "members"

module Assert = struct 
  let created           id = id
  let can_invite        id = id
  let admin             id = id
  let view              id = id
  let bot               id = id
end

module Deduce = struct
end
