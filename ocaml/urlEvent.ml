(* © 2012 RunOrg *)

open Ohm
open UrlClientHelper
open UrlR

let home       = ajax [ "home";"events" ]
  
let pre_create = ( object (self)
  inherit rest "r/event/pre-create"
  method build inst crea user = 
    self # rest inst [IInstance.Deduce.make_createEvent_token crea user]
end )
