(* © 2012 RunOrg *)

open Ohm

class base path = object (self)
  inherit O.Action.controller `Client path 
  method root (inst : MInstance.t) = 
    self # key_root (inst # key) 
  method key_root key = 
    "http://"^key^O.Server.suffix^"/"^(self # path)
end

class dflt path = object (self)
  inherit base path 
  method build inst = self # root inst
  method key_build key = self # key_root key 
  method initial inst = self # build inst
  method key_initial key = self # key_build key  
end

class rest _path = object (self)
  val path = _path 
  inherit O.Action.controller `Client (_path^"/*") 
  method rest (inst : MInstance.t) list = 
    self # key_rest (inst # key) list 
  method key_rest key list = 
    "http://"^key^O.Server.suffix^"/"^(UrlCommon.rest path list)
end
  
class ajax using path = object (self)
  inherit [MInstance.t] O.Box.controller using path
  method build inst = self # rest inst []
end    
