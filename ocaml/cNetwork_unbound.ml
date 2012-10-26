(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

let () = UrlNetwork.def_unbound begin fun req res ->

  let uid = CSession.get req in

  let html = Asset_Network_Unbound.render (object
    method navbar = (req # server,uid,None)
  end) in

  CPageLayout.core (req # server) `Network_Unbound html res

end
