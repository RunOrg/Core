(* © 2012 RunOrg *)

open Ohm
open UrlCoreHelper

let link =  object (self)
  inherit rest "b"
  method build (bid:IBroadcast.t) = 
    self # rest  [IBroadcast.to_string bid]
end 
  
let unsubscribe = object (self) 
  inherit rest ~secure:true "no-digest"
  method build uid =
    self # rest [ 
      IUser.to_string uid ;
      IUser.Deduce.make_block_token uid
    ]
  method build_confirm uid = 
    self # rest [ 
      IUser.to_string uid ;
      IUser.Deduce.make_block_token uid ;
      "confirm"
    ]
end
