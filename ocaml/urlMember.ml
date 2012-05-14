(* © 2012 RunOrg *)

open Ohm
open UrlClientHelper
open UrlR
  
let rem () = ( object (self) 
  inherit rest "r/members/remove"
  method build inst category = 
    self # rest inst [IGroup.to_string (MGroup.Get.id category)]
end )
  
let autocomplete = ( object (self)
  inherit rest "r/members/autocomplete"
  method build inst crea user = 
    self # rest inst [IInstance.Deduce.make_seeContacts_token crea user]
end )

let autocomplete_joy = ( object (self)
  inherit rest "r/members/autocomplete-joy"
  method build inst crea user = 
    self # rest inst [IInstance.Deduce.make_seeContacts_token crea user]
end )
