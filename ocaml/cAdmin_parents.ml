(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let make title endpoint arg = object
  method title = (return title : string O.run)
  method url   = Action.url endpoint None arg
end

open UrlAdmin

let home   = make "Administration"  home   () 
let active = make "Instances"       active None
let public = make "Sites Web"       public None
let stats  = make "Statistiques"    stats  ()
let api    = make "API"             api    ()
let unsbs  = make "Désinscriptions" unsbs  () 
let sqlize = make "Export SQL"      sqlize () 
