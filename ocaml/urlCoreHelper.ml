(* © 2012 RunOrg *)

open Ohm

class dflt ?(secure=false) path = object (self)
  inherit O.Action.controller `Core path 
  method build = (if secure then "https://" else "http://")^O.Server.core^"/"^(self # path)
  method initial () = self # build 
end
  
class rest ?(secure=false) _path = object (self)
  val path = _path 
  inherit O.Action.controller `Core (_path^"/*") 
  method rest list = 
    (if secure then "https://" else "http://")^O.Server.core^"/"^(UrlCommon.rest path list)
end
  
class ajax using path = object (self)
  inherit [unit] O.Box.controller using path
  method build = self # rest () []
end
