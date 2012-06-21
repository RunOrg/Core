(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let () = CClient.define UrlClient.Events.def_home begin fun access -> 
  O.Box.fill (Asset_Event_ListPrivate.render (object
    method list = []
    method url_new     = "#"
    method url_options = Some "#" 
  end))
end
