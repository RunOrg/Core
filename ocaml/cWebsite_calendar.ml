(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Left      = CWebsite_left

let () = UrlClient.def_calendar begin fun req res -> 

  let! cuid, key, iid, instance = CClient.extract req res in

  let! future = ohm $ MEntity.All.get_public_future iid in 
  let! list = ohm $ Run.list_filter begin fun entity ->       
    let  eid  = IEntity.decay $ MEntity.Get.id entity in 
    let  url  = Action.url UrlClient.event key eid in 
    let! pic  = ohm $ CPicture.small_opt (MEntity.Get.picture entity) in
    let! name = req_or (return None) begin match MEntity.Get.name entity with 
      | Some (`text  t) -> Some t
      | _               -> None
    end in
    let! date = req_or (return None) $ MEntity.Get.date entity in
    let! date = req_or (return None) $ MFmt.float_of_date date in
    return $ Some (object
      method pic  = pic
      method name = name
      method date = date
      method url  = url 
    end)      
  end future in 
  
  let main = Asset_Website_Calendar.render (object
    method list = list
  end) in

  let left = Left.render ~calendar:false cuid key iid in 
  let html = VNavbar.public `Calendar ~cuid ~left ~main instance in

  CPageLayout.core (`Website_Calendar_Title (instance # name)) html res

end
