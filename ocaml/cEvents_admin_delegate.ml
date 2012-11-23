(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CEvents_admin_common

let () = define UrlClient.Events.def_delegate begin fun parents entity access -> 

  let delegates = MAccess.delegates (MEntity.Get.admin entity) in

  let! remove = O.Box.react IAvatar.fmt begin fun aid _ _ res ->
    let admin = MAccess.remove_delegates [aid] (MEntity.Get.admin entity) in
    let self  = access # self in 
    let! () = ohm $ O.decay (MEntity.set_admins self entity admin) in
    return res
  end in 
  
  O.Box.fill begin 

    let! admin = ohm $ O.decay (MEntity.admin_group_name (access # iid)) in     

    let! delegates = ohm $ O.decay (Run.list_map begin fun aid ->
      let! profile = ohm $ CAvatar.mini_profile aid in 
      return (object
	method pic  = profile # pico
	method name = profile # name
      end)
    end delegates) in 

    let body = Asset_Delegate_List.render (object 
      method kind      = `Event 
      method admins    = admin
      method delegates = delegates
      method add       = None
    end) in

    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ] 
      method here = parents # delegate # title
      method body = body
    end)

  end

end
