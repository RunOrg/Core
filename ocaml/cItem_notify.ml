(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let () = MItem.Notify.define begin fun uid u t info -> 
  return None
end 
