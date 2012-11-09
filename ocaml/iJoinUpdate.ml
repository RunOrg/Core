(* © 2012 RunOrg *)

open Ohm
  
include Id.Phantom

module Assert = struct 
  let cancel id = id
end

module Deduce = struct
end
