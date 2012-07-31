(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let make title endpoint = object
  method title = (return title : string O.run)
  method url   = Action.url endpoint () ()
end

open UrlAdmin

let home    = make "Administration" home
let active  = make "Instances"      active
