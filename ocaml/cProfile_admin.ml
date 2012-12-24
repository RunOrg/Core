(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CProfile_admin_common

module Viewers = CProfile_admin_viewers

let () = define UrlClient.Profile.def_admin begin fun parents entity access -> 

  O.Box.fill begin 
    let choices = Asset_Admin_Choice.render (BatList.filter_map identity [

      Some (object
	method img      = VIcon.Large.tree
	method url      = parents # viewers # url 
	method title    = AdLib.get `Profile_Viewers_Link
	method subtitle = Some (AdLib.get `Profile_Viewers_Sub)
       end) ;
      
    ]) in
    
    Asset_Admin_Page.render (object
      method parents = [ parents # home ] 
      method here  = parents # admin # title 
      method body  = choices
    end)
  end

end
