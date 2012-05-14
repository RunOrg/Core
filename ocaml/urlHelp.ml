(* © 2012 RunOrg *)

open UrlCoreHelper

let help base = object (self)
  inherit rest base
  method build (id:IHelp.t) = 
    self # rest [ IHelp.to_string id ]
end

let view = help "help"
let edit = help "help/_edit"
let save = help "help/_save"

