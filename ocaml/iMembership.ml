(* © 2012 IRunOrg *)

open Ohm

include Id.Phantom

module Assert = struct 
  let write id = id
  let view  id = id
  let bot   id = id
  let self  id = id
  let admin id = id
end

module Deduce = struct
end
