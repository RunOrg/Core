(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CDiscussion_admin_common

module Edit     = CDiscussion_admin_edit
module Delete   = CDiscussion_admin_delete

let () = define UrlClient.Discussion.def_admin begin fun parents entity access -> 
  O.Box.fill begin 
    let choices = Asset_Admin_Choice.render [

      (object
	method img      = VIcon.Large.page_edit
	method url      = parents # edit # url 
	method title    = AdLib.get `Discussion_Edit_Link
	method subtitle = Some (AdLib.get `Discussion_Edit_Sub)
       end) ;
      
      (object
	method img      = VIcon.Large.cross
	method url      = parents # delete # url 
	method title    = AdLib.get `Discussion_Delete_Link
	method subtitle = Some (AdLib.get `Discussion_Delete_Sub)
       end) ;

    ] in
    
    Asset_Admin_Page.render (object
      method parents = [ parents # home ] 
      method here  = parents # admin # title 
      method body  = choices
    end)
  end
end
