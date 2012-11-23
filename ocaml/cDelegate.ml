(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module DelPickArgs = Fmt.Make(struct
  type json t = (IAvatar.t list) 
end)

let picker kind back access entity wrap = 

  let! post = O.Box.react Fmt.Unit.fmt begin fun _ json _ res ->

    let aids = BatOption.default [] (DelPickArgs.of_json_safe json) in

    let admin = MAccess.add_delegates aids (MEntity.Get.admin entity) in
    let self  = access # self in 
    let! () = ohm $ O.decay (MEntity.set_admins self entity admin) in

    return $ Action.javascript (Js.redirect ~url:back ()) res

  end in

  wrap begin 

    let! submit = ohm $ AdLib.get (`Delegate_Submit kind) in

    Asset_Search_Pick.render (object
      method submit = submit
      method search = Action.url UrlClient.Search.avatars (access # instance # key) () 
      method post   = OhmBox.reaction_json post () 
    end)

  end

let list kind pick access entity wrap = 

  let delegates = MAccess.delegates (MEntity.Get.admin entity) in

  let! remove = O.Box.react IAvatar.fmt begin fun aid _ _ res ->
    let admin = MAccess.remove_delegates [aid] (MEntity.Get.admin entity) in
    let self  = access # self in 
    let! () = ohm $ O.decay (MEntity.set_admins self entity admin) in
    return res
  end in 
  
  wrap begin 

    let! admin = ohm $ MEntity.admin_group_name (access # iid) in     

    let! delegates = ohm $ Run.list_map begin fun aid ->
      let! profile = ohm $ CAvatar.mini_profile aid in 
      let remove = OhmBox.reaction_endpoint remove aid in 
      return (object
	method pic    = profile # pico
	method name   = profile # name
	method remove = JsCode.Endpoint.to_json remove
      end)
    end delegates in 

    Asset_Delegate_List.render (object 
      method kind      = kind 
      method admins    = admin
      method delegates = delegates
      method add       = pick
    end)
      
  end
