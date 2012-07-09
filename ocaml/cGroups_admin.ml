(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CGroups_admin_common

module People = CGroups_admin_people
module Join   = CGroups_admin_join

let () = define UrlClient.Members.def_admin begin fun parents entity access -> 

  O.Box.fill begin 
    let choices = Asset_Admin_Choice.render [

      (object
	method img      = VIcon.Large.cog_edit
	method url      = parents # edit # url 
	method title    = AdLib.get `Group_Edit_Link
	method subtitle = Some (AdLib.get `Group_Edit_Sub)
       end) ;
      
      (object
	method img      = VIcon.Large.group
	method url      = parents # people # url 
	method title    = AdLib.get `Group_People_Link
	method subtitle = Some (AdLib.get `Group_People_Sub)
       end) ;
      
    ] in
    
    Asset_Admin_Page.render (object
      method parents = [ parents # home ] 
      method here  = parents # admin # title 
      method body  = choices
    end)
  end

end
