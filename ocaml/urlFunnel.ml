(* © 2012 RunOrg *)

open Ohm
open UrlCoreHelper

let start   = new dflt "start"            

let restart = object (self) 
  inherit rest ~secure:true "start"   
  method build (id:IFunnel.t) = 
    self # rest [ IFunnel.to_string id ]
end

let pick     = object (self) 
  inherit rest ~secure:true "start/1"
  method build (v:IVertical.t) = 
    self # rest [ IVertical.to_string v ]
  method build_edit (v:IVertical.t) (id:IFunnel.t) = 
    self # rest [ IVertical.to_string v ; IFunnel.to_string id ]
end

let edit    = object (self)
  inherit rest ~secure:true "start/2"
  method build (id:IFunnel.t) = 
    self # rest [ IFunnel.to_string id ]
end

let post    = object (self) 
  inherit rest ~secure:true "start/2/post"
  method build (id:IFunnel.t) = 
    self # rest [ IFunnel.to_string id ]
end

let account = object (self) 
  inherit rest ~secure:true "start/3"
  method build (id:IFunnel.t) = 
    self # rest [ IFunnel.to_string id ]
end

let do_login = object (self)
  inherit rest ~secure:true "start/3/login"   
  method build (id:IFunnel.t) = 
    self # rest [ IFunnel.to_string id ]
end

let signup   = object (self) 
  inherit rest ~secure:true "start/3/signup"  
  method build (id:IFunnel.t) = 
    self # rest [ IFunnel.to_string id ]
end

let facebook = object (self)
  inherit rest ~secure:true "start/3/facebook"
  method build (id:IFunnel.t) = 
    self # rest [ IFunnel.to_string id ]
end

let free_name = new dflt ~secure:true "start/free-instance-name"

let create = object (self)
  inherit rest ~secure:true "start/create"
  method build (id:IFunnel.t) = 
    self # rest [ IFunnel.to_string id ]
  method confirm (id:IFunnel.t) (uid:[`CanLogin] IUser.id) = 
    self # rest [ IFunnel.to_string id ;
		  IUser.to_string uid ;
		  IUser.Deduce.make_login_token uid ]
end 
