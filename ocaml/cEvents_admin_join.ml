(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CEvents_admin_common

let () = define UrlClient.Events.def_join begin fun parents entity access -> 

  let! aid = O.Box.parse IAvatar.seg in 

  let fail = O.Box.fill begin

    let body = Asset_Event_DraftNoPeople.render (parents # edit # url) in

    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ] 
      method here = parents # people # title
      method body = body
    end)

  end in 

  let  draft  = MEntity.Get.draft entity in 

  let  gid = MEntity.Get.group entity in
  let! group = ohm $ O.decay (MGroup.try_get access gid) in
  let! group = ohm $ O.decay (Run.opt_bind MGroup.Can.write group) in
  let  group = if draft then None else group in   
  let! group = req_or fail group in 

  O.Box.fill begin 

    let! profile = ohm $ O.decay (CAvatar.mini_profile aid) in
    let! mid     = ohm $ O.decay (MMembership.as_admin (MGroup.Get.id group) aid) in 
    let! mbr     = ohm $ O.decay (MMembership.get mid) in 

    let mbr = BatOption.default (MMembership.default ~mustpay:false ~group:gid ~avatar:aid) mbr in
    let gender = None in
    let status = match mbr.MMembership.status with 
      | `Unpaid   -> Some (`Unpaid gender)
      | `Pending  -> Some (`Pending gender)
      | `Invited  -> Some (`Invited gender)
      | `Member   -> Some (`GroupMember gender)
      | `Declined -> Some (`Declined gender)
      | `NotMember -> None
    in

    let body = Asset_Join_Edit.render (object
      method picture = Some (profile # pic)
      method name    = profile # name
      method status  = status
    end) in

    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ; parents # people ] 
      method here = return (profile # name) 
      method body = body 
    end)

  end


end 
