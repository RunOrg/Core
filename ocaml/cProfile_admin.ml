(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CProfile_admin_common

let () = define UrlClient.Profile.def_admin begin fun parents entity access -> 

  O.Box.fill begin 
    let choices = Asset_Admin_Choice.render (BatList.filter_map identity [

      Some (object
	method img      = VIcon.Large.cog_edit
	method url      = parents # parents # url 
	method title    = AdLib.get `Profile_Parents_Link
	method subtitle = Some (AdLib.get `Profile_Parents_Sub)
       end) ;
      
    ]) in
    
    Asset_Admin_Page.render (object
      method parents = [ parents # home ] 
      method here  = parents # admin # title 
      method body  = choices
    end)
  end

end
