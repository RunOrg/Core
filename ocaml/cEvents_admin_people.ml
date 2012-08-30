(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CEvents_admin_common

let () = define UrlClient.Events.def_people begin fun parents entity access -> 
  
  (* What to do if the group is not available ? *)

  let fail = O.Box.fill begin

    let body = Asset_Event_DraftNoPeople.render (parents # edit # url) in

    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ] 
      method here = parents # people # title
      method body = body
    end)

  end in 

  let cols_url = 
    Action.url UrlClient.Events.cols (access # instance # key) 
      [ IEntity.to_string (MEntity.Get.id entity) ] 
  in  

  let join_url aid = 
    Action.url UrlClient.Events.join (access # instance # key) 
      [ IEntity.to_string (MEntity.Get.id entity) ;
	IAvatar.to_string aid ] 
  in
  
  let invite_url = 
    Action.url UrlClient.Events.invite (access # instance # key) 
      [ IEntity.to_string (MEntity.Get.id entity) ]
  in
  
  (* Return the box containing the grid. *)

  let wrapper body = 
    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ] 
      method here = parents # people # title
      method body = body
    end)
  in

  CGrid.box access entity fail cols_url invite_url join_url wrapper

end
