(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

let () = UrlNetwork.def_unbound begin fun req res ->
  return res
end
