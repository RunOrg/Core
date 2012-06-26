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

    let! name = ohm $ CEntityUtil.name entity in
    let! pic  = ohm $ CEntityUtil.pic_large entity in
    let! desc = ohm $ CEntityUtil.desc entity in
    
    Asset_Event_Page.render (object
      method pic        = pic
      method navig      = []
      method admin      = None
      method title      = name
      method pic_change = None 
      method date       = None
      method status     = None
      method desc       = desc
      method time       = None
      method location   = None
      method details    = "/"
      method box        = Html.str "O Hai" 
    end)
  end
end
