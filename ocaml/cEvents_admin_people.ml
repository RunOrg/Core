(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CEvents_admin_common

let () = define UrlClient.Events.def_people begin fun parents event access -> 
  
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
      [ IEvent.to_string (MEvent.Get.id event) ] 
  in  

  let join_url aid = 
    Action.url UrlClient.Events.join (access # instance # key) 
      [ IEvent.to_string (MEvent.Get.id event) ;
	IAvatar.to_string aid ] 
  in
  
  let invite_url = 
    Action.url UrlClient.Events.invite (access # instance # key) 
      [ IEvent.to_string (MEvent.Get.id event) ]
  in
  
  (* Return the box containing the grid. *)

  let wrapper body = 
    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ] 
      method here = parents # people # title
      method body = body
    end)
  in

  if MEvent.Get.draft event then fail else 
    let gid = MEvent.Get.group event in
    CGrid.box access gid fail cols_url invite_url join_url wrapper

end
