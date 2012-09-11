(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CForums_admin_common

module Delete = CForums_admin_delete

let () = define UrlClient.Forums.def_admin begin fun parents entity access -> 
  
  let is_group   = MEntity.Get.kind entity = `Group in 
  let is_private = CEntityUtil.private_forum entity in 

  O.Box.fill begin 
    let choices = Asset_Admin_Choice.render (BatList.filter_map identity [

      Some (object
	method img      = VIcon.Large.comment_edit
	method url      = parents # edit # url 
	method title    = AdLib.get `Forum_Edit_Link
	method subtitle = Some (AdLib.get `Forum_Edit_Sub)
       end) ;
      
      ( if not is_group && is_private then 
	  Some (object
	    method img      = VIcon.Large.group
	    method url      = parents # people # url 
	    method title    = AdLib.get `Forum_People_Link
	    method subtitle = Some (AdLib.get `Forum_People_Sub)
	  end) 
	else
	  None ) ;
      
      (if not is_group then
	  Some (object
	    method img      = VIcon.Large.cross
	    method url      = parents # delete # url
	    method title    = AdLib.get `Forum_Delete_Link
	    method subtitle = Some (AdLib.get `Forum_Delete_Sub) 
	  end)
       else
	  None ) ;

    ]) in
    
    Asset_Admin_Page.render (object
      method parents = [ parents # home ] 
      method here  = parents # admin # title 
      method body  = choices
    end)
  end

end
