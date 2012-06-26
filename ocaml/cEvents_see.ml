(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let () = CClient.define UrlClient.Events.def_see begin fun access -> 
  O.Box.fill $ O.decay begin
    Asset_Event_Page.render (object
      method pic = "" 
      method navig = []
      method admin = None
      method title = ""
      method pic_change = None 
      method date  = None
      method status = None
      method desc = None
      method time = None
      method location = None
      method details = "/"
      method box = Html.str "O Hai" 
    end)
  end
end
