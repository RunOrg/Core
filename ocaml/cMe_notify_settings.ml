(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CMe_common

let () = define UrlMe.Notify.def_settings begin fun cuid -> 

  O.Box.fill begin
    
    Asset_Admin_Page.render (object
      method parents = [ object
	method title = AdLib.get `Notify_Title
	method url   = Action.url UrlMe.Notify.home () () 
      end ]
      method here  = AdLib.get `Notify_Settings_Title
      method body  = Asset_Form_Clean.render (return ignore)
    end)

  end
end
