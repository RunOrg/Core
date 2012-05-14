(* © 2012 IRunOrg *)

open Ohm

include Id.Phantom

module Assert = struct 
  let write id = id
  let read  id = id
  let bot   id = id
end

module Deduce = struct
end
