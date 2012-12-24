(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module See     = CEvents_see
module Create  = CEvents_create
module Options = CEvents_options
module Admin   = CEvents_admin

let unnamed = AdLib.get `Event_Unnamed

let render_event access event =
  let! now  = ohmctx (#time) in   
  let! name = ohm $ BatOption.default unnamed (BatOption.map return (MEvent.Get.name event)) in
  let! pic  = ohm $ CPicture.small_opt (MEvent.Get.picture event) in
  let  date = BatOption.map Date.to_timestamp (MEvent.Get.date event) in
  let! coming = ohm begin 	
    let! ()    = true_or (return None) (not (MEvent.Get.draft event)) in
    let  gid   = MEvent.Get.group event in 
    let! group = ohm_req_or (return None) $ MGroup.try_get (access # actor) gid in
    let! group = ohm_req_or (return None) $ MGroup.Can.list group in
    let  gid   = MGroup.Get.id group in 
    let! count = ohm $ MMembership.InGroup.count gid in
    return $ Some (count # count) 
  end in            
  let status = BatOption.map (fun s -> (s :> VStatus.t)) (MEvent.Get.status event) in
  return (object
    method coming = coming 
    method date   = BatOption.map (fun t -> (t,now)) date
    method pic    = pic
    method status = status 
    method title  = name
    method url    = Action.url UrlClient.Events.see (access # instance # key) 
      [ IEvent.to_string (MEvent.Get.id event) ] 
  end)

let () = CClient.define UrlClient.Events.def_home begin fun access -> 
  O.Box.fill $ O.decay begin 

    (* Construct the list of entities to be displayed *)
    let! now = ohmctx (#time) in
    let  iid = access # iid in 
    let  actor = access # actor in 

    let! future = ohm $ MEvent.All.future ~actor iid in
    let! future = ohm $ Run.list_map (render_event access) future in 

    let! undated = ohm $ MEvent.All.undated ~actor iid in
    let! undated = ohm $ Run.list_map (render_event access) undated in 

    let! past, _ = ohm $ MEvent.All.past ~actor ~count:10 iid in
    let! past = ohm $ Run.list_map (render_event access) past in 

    (* The URL of the options page *)
    let options = 
      if None = CAccess.admin access then None else 
	Some (Action.url UrlClient.Events.options (access # instance # key) [])
    in
    Asset_Event_ListPrivate.render (object
      method future      = future
      method undated     = undated
      method past        = past
      method url_new     = Action.url UrlClient.Events.create (access # instance # key) []
      method url_options = options
    end) 
  end
end

