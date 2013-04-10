(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal

let core uid owid = object
  method white = owid
  method name  = None
  method url   = None
  method unsub = Action.url UrlMail.unsubscribe owid (IUser.decay uid, None)
end

let instance uid i = object
  method white = snd (i # key) 
  method name  = Some (i # name)
  method url   = Some (Action.url UrlClient.website (i # key) ()) 
  method unsub = Action.url UrlMail.unsubscribe (snd (i # key)) (IUser.decay uid, Some i # id) 
end
  
