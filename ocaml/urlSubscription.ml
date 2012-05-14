(* © 2012 RunOrg *)

open Ohm
open UrlClientHelper
open UrlR

let home     = ajax [ "home";"subscriptions" ]
  
let start    = new dflt "join"
let finish   = new dflt "join/end"
  
let form ()     = ( object (self)
  inherit rest "join"
  method build instance eid = 
    self # rest instance [IEntity.to_string eid]
end )
  
let submit ()   = ( object (self)
  inherit rest "join/post"
  method build instance eid = 
    self # rest instance [IEntity.to_string eid]
end )
