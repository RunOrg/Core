(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CEvents_admin_common

let () = define UrlClient.Events.def_invite begin fun parents entity access -> 
  
  let fail = O.Box.fill begin

    let body = Asset_Event_DraftNoPeople.render (parents # edit # url) in

    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ; parents # people ] 
      method here = parents # invite # title
      method body = body
    end)

  end in 

  let wrapper body = 
    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ; parents # people ] 
      method here = parents # invite # title
      method body = body
    end)
  in

  let  draft  = MEntity.Get.draft entity in 

  let  gid = MEntity.Get.group entity in
  let! group = ohm $ O.decay (MGroup.try_get access gid) in
  let! group = ohm $ O.decay (Run.opt_bind MGroup.Can.admin group) in
  let  group = if draft then None else group in   
  let! group = req_or fail group in 

  let url s = 
    Action.url UrlClient.Events.invite (access # instance # key) 
      [ IEntity.to_string (MEntity.Get.id entity) ; s ]
  in

  let back = 
    Action.url UrlClient.Events.people (access # instance # key) 
      [ IEntity.to_string (MEntity.Get.id entity) ]
  in

  CInvite.box `Event url back access (MGroup.Get.id group) wrapper

end
