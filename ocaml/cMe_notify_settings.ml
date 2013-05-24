(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CMe_common

module Block = CMe_notify_settings_block

let () = define UrlMe.Notify.def_settings begin fun owid cuid -> 
  O.Box.fill begin

    let choices = Asset_Admin_Choice.render [
      
      (object
	method img      = VIcon.Large.email_delete
	method url      = Action.url UrlMe.Notify.block owid ()
	method title    = AdLib.get `Notify_Settings_Block_Link
	method subtitle = Some (AdLib.get `Notify_Settings_Block_Sub)
       end) ;
      
      (object
	method img      = VIcon.Large.report_go
	method url      = Action.url UrlMe.Notify.digest owid ()
	method title    = AdLib.get `Notify_Settings_Digest_Link
	method subtitle = Some (AdLib.get `Notify_Settings_Digest_Sub)
       end) ;

    ] in 
    
    Asset_Admin_Page.render (object
      method parents = [] 
      method here  = AdLib.get `Notify_Settings_Title
      method body  = choices
    end)

  end
end
