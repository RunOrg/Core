(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

let count = 9

let () = UrlClient.Search.def_avatars $ CClient.action begin fun access req res ->

  let  iid   = IInstance.Deduce.token_see_contacts (access # iid) in

  let! list  = ohm $ MAvatar.search iid (BatOption.default "" (req # get "prefix")) count in

  let! htmls = ohm $ Run.list_filter begin fun (aid,prefix,details) ->
    let! name = req_or (return None) (details # name) in
    let! status = req_or (return None) (details # status) in
    let! pic  = ohm $ CPicture.small_opt (details # picture) in
    let  data = object
      method id = aid 
      method name = name
      method pic  = pic
      method status = status
    end in 
    let! html = ohm $ Asset_Search_Avatar.render data in
    return (Some (Html.to_json html))
  end list in

  let htmls = BatList.take count htmls in

  return (Action.json [ "list", Json.Array htmls ] res)

end

module AvatarOrGroup = Fmt.Make(struct
  type json t = [ `Avatar "a" of IAvatar.t | `Group "g" of IGroup.t ]
end)

let groups access = 
  let! list = ohm $ MGroup.All.visible ~actor:(access # actor) (access # iid) in
  Run.list_map (fun group -> 
    let! name = ohm $ MGroup.Get.fullname group in 
    let  eid  = IGroup.decay (MGroup.Get.id group) in
    return (`Group eid, name, return (Html.esc name)) 
  ) list

let target_picker ?(query=true) access = 
  let! static = ohm (if query then groups access else return []) in 
  let  dynamic = JsCode.Endpoint.of_url (Action.url UrlClient.Search.target (access # instance # key) ()) in
  return (begin fun ?left ~label ?max seed parse ->
    VEliteForm.picker ?left ~label ~format:AvatarOrGroup.fmt ~dynamic ~static ?max seed parse
  end) 

let () = UrlClient.Search.def_target $ CClient.action begin fun access req res ->

  let result list =   
    let! json = ohm $ VEliteForm.Picker.formatResults AvatarOrGroup.fmt list in
    return (Action.json json res)
  in

  let! json = req_or (result []) (Action.Convenience.get_json req) in
  let! mode = req_or (result []) (VEliteForm.Picker.QueryFmt.of_json_safe json) in
  
  let iid  = IInstance.Deduce.token_see_contacts (access # iid) in

  let by_prefix prefix =
    
    let  count = 10 in
    let! list  = ohm $ MAvatar.search iid prefix count in
    let  render aid details = 
      let! profile = ohm $ CAvatar.mini_profile_from_details aid details in 
      Asset_Avatar_PickerLine.render profile
    in
    result (List.map (fun (aid, _, details) -> (`Avatar aid, render aid details)) list)
    
  in

  let by_json aids = 
    let  aids = BatList.filter_map AvatarOrGroup.of_json_safe aids in 
    let  aids = BatList.filter_map (function `Avatar aid -> Some aid | `Group _ -> None) aids in 
    let! list = ohm $ Run.list_map begin fun aid ->
      let! profile = ohm $ CAvatar.mini_profile aid in
      return (`Avatar aid, Asset_Avatar_PickerLine.render profile)
    end aids in
    result list
  in

  match mode with 
    | `ByJson   ids    -> by_json  ids
    | `ByPrefix prefix -> by_prefix prefix


end 
