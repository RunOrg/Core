(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let render iid key = 

  let! calendar = ohm begin 
    
    let  url  = Action.url UrlClient.calendar key () in 

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

    let list = BatList.take 3 list in
    
    if list <> [] then
      Asset_Website_MiniCalendar.render (object
	method url  = url
	method list = list
      end)      
    else
      return $ Html.str "" 

  end in 

  let! subscribe = ohm begin 

    let! num_brc = ohm $ MBroadcast.count iid in 
    let! num_sbs = ohm $ MDigest.Subscription.count_followers iid in 

    Asset_Website_Subscribe.render (object
      method num_brc = num_brc
      method num_sbs = num_sbs
    end) 

  end in 

  return ( Html.concat [ calendar ; subscribe ] )
