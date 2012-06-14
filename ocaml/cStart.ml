(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let () = UrlStart.def_home begin fun req res -> 
  let html = Asset_Start_Page.render () in
  CPageLayout.core `Me_Title html res 
end
