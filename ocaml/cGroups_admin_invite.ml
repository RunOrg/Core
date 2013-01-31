(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CGroups_admin_common

let () = define UrlClient.Members.def_invite begin fun parents group access -> 
  
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

  let  asid = MGroup.Get.group group in
  let! avset = ohm $ O.decay (MAvatarSet.try_get (access # actor) asid) in
  let! avset = ohm $ O.decay (Run.opt_bind MAvatarSet.Can.admin avset) in
  let! avset = req_or fail avset in 

  let url s = 
    Action.url UrlClient.Members.invite (access # instance # key) 
      [ IGroup.to_string (MGroup.Get.id group) ; s ]
  in

  let back = 
    Action.url UrlClient.Members.people (access # instance # key) 
      [ IGroup.to_string (MGroup.Get.id group) ]
  in

  CInvite.box `Group url back access (MAvatarSet.Get.id avset) wrapper

end
