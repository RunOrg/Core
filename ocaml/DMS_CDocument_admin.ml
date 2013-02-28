(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open DMS_CDocument_common 
open DMS_CDocument_admin_common

module Edit   = DMS_CDocument_admin_edit
module Delete = DMS_CDocument_admin_delete
module Share  = DMS_CDocument_admin_share

let () = define Url.Doc.def_admin begin fun parents rid doc access ->
  O.Box.fill begin 

    let choices = Asset_Admin_Choice.render [

      (object
	method img = VIcon.Large.page_edit
	method url = parents # edit # url
	method title = AdLib.get `DMS_Document_Edit_Link
	method subtitle = Some (AdLib.get `DMS_Document_Edit_Sub)
       end) ;

      (object
	method img = VIcon.Large.arrow_branch
	method url = parents # share # url
	method title = AdLib.get `DMS_Document_Share_Link
	method subtitle = Some (AdLib.get `DMS_Document_Share_Sub)
       end) ;

      (object
	method img = VIcon.Large.cross
	method url = parents # delete # url
	method title = AdLib.get `DMS_Document_Delete_Link
	method subtitle = Some (AdLib.get `DMS_Document_Delete_Sub)
       end) ;

    ] in

    Asset_Admin_Page.render (object
      method parents = [ parents # home ]
      method here = parents # admin # title
      method body = choices
    end)
  end 
end
