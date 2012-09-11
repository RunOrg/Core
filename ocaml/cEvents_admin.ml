(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CEvents_admin_common

module Edit    = CEvents_admin_edit
module Picture = CEvents_admin_picture
module Access  = CEvents_admin_access
module People  = CEvents_admin_people
module Join    = CEvents_admin_join
module Invite  = CEvents_admin_invite
module JForm   = CEvents_admin_jForm
module Columns = CEvents_admin_cols

let () = define UrlClient.Events.def_admin begin fun parents entity access -> 
  O.Box.fill begin 
    let choices = Asset_Admin_Choice.render [

      (object
	method img      = VIcon.Large.date_edit
	method url      = parents # edit # url 
	method title    = AdLib.get `Event_Edit_Link
	method subtitle = Some (AdLib.get `Event_Edit_Sub)
       end) ;
      
      (object
	method img      = VIcon.Large.image
	method url      = parents # picture # url 
	method title    = AdLib.get `Event_Picture_Link
	method subtitle = Some (AdLib.get `Event_Picture_Sub)
       end) ;

      (object
	method img      = VIcon.Large.group
	method url      = parents # people # url 
	method title    = AdLib.get `Event_People_Link
	method subtitle = Some (AdLib.get `Event_People_Sub)
       end) ;
      
      (object
	method img      = VIcon.Large.key
	method url      = parents # access # url 
	method title    = AdLib.get `Event_Access_Link
	method subtitle = Some (AdLib.get `Event_Access_Sub)
       end) ;

      (object
	method img      = VIcon.Large.textfield
	method url      = parents # jform # url 
	method title    = AdLib.get `Event_JoinForm_Link
	method subtitle = Some (AdLib.get `Event_JoinForm_Sub)
       end) ;

      (object
	method img      = VIcon.Large.cross
	method url      = ""
	method title    = AdLib.get `Event_Delete_Link
	method subtitle = Some (AdLib.get `Event_Delete_Sub)
       end) ;

    ] in
    
    Asset_Admin_Page.render (object
      method parents = [ parents # home ] 
      method here  = parents # admin # title 
      method body  = choices
    end)
  end
end
