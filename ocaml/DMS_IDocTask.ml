(* © 2013 RunOrg *)

open Ohm
open BatPervasives
  
include Id.Phantom

module Assert = struct 
  let view   = identity
end
