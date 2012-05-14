(* © 2012 RunOrg *)

open Ohm
open UrlClientHelper
open UrlR

let autocomplete = ( object (self)
  inherit rest "r/access/autocomplete"
  method build inst crea user = 
    self # rest inst [IInstance.Deduce.make_seeContacts_token crea user]
end )
