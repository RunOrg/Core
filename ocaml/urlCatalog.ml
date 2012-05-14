(* © 2012 Runorg *)

open Ohm
open UrlCoreHelper

let index = new dflt "catalog"

let product = new dflt "product"

let page = object (self)
  inherit rest "catalog"              
  method build seg = 
    self # rest [ seg ]
end
