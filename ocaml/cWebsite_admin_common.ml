(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let wrap access title body = 
  Asset_Admin_Page.render (object
    method parents = [ object
      method title = return (access # instance # name)
      method url   = Action.url UrlClient.website (access # instance # key) ()
    end ]
    method here = AdLib.get title
    method body = body
  end)
