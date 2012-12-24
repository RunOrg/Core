(* © 2012 RunOrg *)

open Ohm
open BatPervasives
  
include Id.Phantom

module Assert = struct 
end

module Deduce = struct
end

module View = struct
  type t = Id.t
  let of_id = identity
  let to_id = identity
  let make ilid aid = 
    Id.of_string (to_string ilid ^ "-" ^ IAvatar.to_string aid) 
end
