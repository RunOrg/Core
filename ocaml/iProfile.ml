(* © 2012 RunOrg *)

open Ohm

include Id.Phantom

module Assert = struct 
  let is_self     id = id
  let admin       id = id
  let created     id = id
  let updated     id = id
  let view        id = id
end
  
module Deduce = struct
  let self_can_view   id = id
  let create_can_view id = id
end

