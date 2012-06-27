(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let () = CClient.define UrlClient.Events.def_see begin fun access -> 

  let e404 = O.Box.fill (Asset_Client_PageNotFound.render ()) in

  let! eid = O.Box.parse IEntity.seg in

  let! entity = ohm_req_or e404 $ O.decay (MEntity.try_get access eid) in
  let! entity = ohm_req_or e404 $ O.decay (MEntity.Can.view entity) in

  O.Box.fill $ O.decay begin

    let! now  = ohmctx (#time) in

    let  tmpl = MEntity.Get.template entity in 
    let! name = ohm $ CEntityUtil.name entity in
    let! pic  = ohm $ CEntityUtil.pic_large entity in
    let! desc = ohm $ CEntityUtil.desc entity in
    let  date = BatOption.bind MFmt.float_of_date (MEntity.Get.date entity) in 
    let! loc  = ohm begin 
      match PreConfig_Template.Meaning.location tmpl with None -> return None | Some field -> 
	let! data = ohm $ CEntityUtil.data entity in
	return (try Some (Json.to_string (List.assoc field data)) with _ -> None)
    end in 
    
    let location = 
      match loc with None -> None | Some addr -> 
	Some (object
	  method url  = "http://maps.google.fr/maps?f=q&hl=fr&q="^addr
	  method name = addr
	 end)
    in

    Asset_Event_Page.render (object
      method pic        = pic
      method navig      = []
      method admin      = None
      method title      = name
      method pic_change = None 
      method date       = BatOption.map (fun t -> (t,now)) date
      method status     = None
      method desc       = desc
      method time       = date
      method location   = location
      method details    = "/"
      method box        = Html.str "O Hai" 
    end)
  end
end
