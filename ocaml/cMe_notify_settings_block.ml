(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CMe_common

let () = define UrlMe.Notify.def_block begin fun owid cuid -> 
  O.Box.fill begin

    let body = return ignore in 
    
    Asset_Admin_Page.render (object
      method parents = [ object
	method url   = Action.url UrlMe.Notify.settings owid () 
	method title = AdLib.get `Notify_Settings_Title
      end ] 
      method here  = AdLib.get `Notify_Settings_Block_Title
      method body  = body
    end)

  end
end
