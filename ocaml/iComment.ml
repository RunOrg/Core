(* © 2012 RunOrg *)

open Ohm

include Id.Phantom
  
module Assert = struct 
  let created     id = id
  let read        id = id
end
  
module Deduce = struct
end

