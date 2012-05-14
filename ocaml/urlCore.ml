(* © 2012 RunOrg *)

open UrlCoreHelper

let all = new dflt "*"

let not_found     = new dflt "*"
let cancel        = new dflt "cancel"
  
let ping          = new dflt "ping"

let retrack       = new dflt "retrack"
  
let logout        = new dflt "logout"        

let setpass       = ( object (self)
  inherit rest ~secure:true "sp"
  method build id = 
    self # rest [
      IUser.to_string id ; 
      IUser.Deduce.make_login_token id
    ]
end )

let notify () = ( object (self)
  inherit rest ~secure:true "nt"
  method build id (notif : [<`Send|`Read] INotification.id) = 
    self # rest [
      INotification.to_string notif ;     
      IUser.Deduce.make_login_token id
    ]
end )
  
let message () = ( object (self) 
  inherit rest ~secure:true "ms"
  method build user message = 
    self # rest [
      IMessage.to_string message ;
      IUser.to_string user ;
      IUser.Deduce.make_login_token user
    ]
end )
