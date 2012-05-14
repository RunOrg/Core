(* © 2012 RunOrg *)

open Ohm
open UrlCoreHelper

let explore = object (self) 
  inherit rest "network/explore"
  method build tags = self # rest tags
end

let profile = object (self) 
  inherit rest "network"            
  method build (iid:IInstance.t) = self # rest [IInstance.to_string iid] 
  method build_bid (iid:IInstance.t) (bid:IBroadcast.t) = 
    self # rest [IInstance.to_string iid; IBroadcast.to_string bid] 
end

let subscribe = object (self) 
  inherit rest "network/subscribe"
  method build (iid:IInstance.t) = self # rest [IInstance.to_string iid] 
end
