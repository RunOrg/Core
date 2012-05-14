(* © 2012 RunOrg *)

open Ohm

let free_name = object (self)
  inherit UrlCoreHelper.dflt "api/free-instance-name"
  method ask id = Js.askServer (self # build) ["name",id] []
end
