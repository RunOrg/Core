(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let () = UrlSplash.def_index begin fun req res -> 

  let cuid = CSession.get req in 
  C404.render cuid res

end

let () = UrlSplash.def_sindex begin fun req res -> 

  let url = Action.url UrlSplash.index () (req # args) in
  return $ Action.redirect url res

end
