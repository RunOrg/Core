(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let render ?(calendar=true) cuid key iid = 

  let! calendar = ohm begin 

    if calendar then 
    
      let  url  = Action.url UrlClient.calendar key () in 
      
      let! future = ohm $ MEvent.All.future iid in 
      let! list = ohm $ Run.list_filter begin fun event ->       
	let  eid  = IEvent.decay $ MEvent.Get.id event in 
	let  url  = Action.url UrlClient.event key eid in 
	let! pic  = ohm $ CPicture.small_opt (MEvent.Get.picture event) in
	let! name = req_or (return None) (MEvent.Get.name event) in
	let! date = req_or (return None) $ MEvent.Get.date event in
	let  date = Date.to_timestamp date in  
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
	  
    else

      return $ Html.str "" 

  end in 

  return calendar
