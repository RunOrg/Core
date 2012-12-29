(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CGroups_admin_common

let () = define UrlClient.Members.def_invite begin fun parents entity access -> 
  
  let fail = O.Box.fill begin

    let body = Asset_Group_Missing.render (parents # home # url) in

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

  let  gid = MEntity.Get.group entity in
  let! group = ohm $ O.decay (MGroup.try_get (access # actor) gid) in
  let! group = ohm $ O.decay (Run.opt_bind MGroup.Can.admin group) in
  let! group = req_or fail group in 

  let url s = 
    Action.url UrlClient.Members.invite (access # instance # key) 
      [ IEntity.to_string (MEntity.Get.id entity) ; s ]
  in

  let back = 
    Action.url UrlClient.Members.people (access # instance # key) 
      [ IEntity.to_string (MEntity.Get.id entity) ]
  in

  CInvite.box `Group url back access (MGroup.Get.id group) wrapper

end
