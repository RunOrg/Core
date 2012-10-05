(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let () = UrlLogin.def_logout begin fun req res -> 

  let url = Action.url UrlLogin.login (req # server) [] in
  return $ Action.redirect url (CSession.close res) 

end
