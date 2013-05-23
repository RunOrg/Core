(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open DMS_CRepository_common 
open DMS_CRepository_admin_common

module Delete = DMS_CRepository_admin_delete
module Edit   = DMS_CRepository_admin_edit

let () = define Url.Repo.def_admin begin fun parents repo access ->
  O.Box.fill (O.decay begin 

    let choices = Asset_Admin_Choice.render (BatList.filter_map identity [

      Some (object
	method img = VIcon.Large.page_edit
	method url = parents # edit # url
	method title = AdLib.get `DMS_Repo_Edit_Link
	method subtitle = Some (AdLib.get `DMS_Repo_Edit_Sub)
      end) ;

      if MRepository.Get.upload repo <> `Viewers then Some (object
	method img = VIcon.Large.folder_key
	method url = parents # uploaders # url
	method title = AdLib.get `DMS_Repo_Uploaders_Link
	method subtitle = Some (AdLib.get `DMS_Repo_Uploaders_Sub)
      end) else None ;

      Some (object
	method img = VIcon.Large.cross
	method url = parents # delete # url
	method title = AdLib.get `DMS_Repo_Delete_Link
	method subtitle = Some (AdLib.get `DMS_Repo_Delete_Sub)
      end) ; 

    ]) in

    Asset_Admin_Page.render (object
      method parents = [ parents # home ]
      method here = parents # admin # title
      method body = choices
    end)

  end) 
end
