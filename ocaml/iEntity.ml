(* © 2012 IRunOrg *)

open Ohm
  
include Id.Phantom

module Assert = struct 
  let created           id = id
  let can_invite        id = id
  let admin             id = id
  let view              id = id
  let bot               id = id
end

module Deduce = struct
end
