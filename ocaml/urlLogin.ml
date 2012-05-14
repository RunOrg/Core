(* © 2012 RunOrg *)

open Ohm
open UrlCoreHelper

let index    = new dflt ~secure:true "login"            
let do_login = new dflt ~secure:true "login/login"   
let signup   = new dflt ~secure:true "login/signup"  
let lost     = new dflt ~secure:true "login/lost"    
let facebook = new dflt ~secure:true "login/facebook"

let fb_channel = new dflt ~secure:true "channel.html"

let merge = ( object (self) 
  inherit rest ~secure:true "login/merge"
  method build id = 
    self # rest [IUser.to_string id ; IUser.Deduce.make_login_token id]
end )

let fb_confirm = ( object (self) 
  inherit rest ~secure:true "login/fb-confirm"
  method build id = 
    self # rest [IUser.to_string id ; IUser.Deduce.make_confirm_token id]
end )
  
let reset    = ( object (self)
  inherit rest ~secure:true "pr"
  method build id = 
    self # rest [IUser.to_string id ; IUser.Deduce.make_login_token id]
end )
  
let confirm  = ( object (self)
  inherit rest ~secure:true "sc" 
  method build id = 
    self # rest [IUser.to_string id ; IUser.Deduce.make_login_token id]
end )
