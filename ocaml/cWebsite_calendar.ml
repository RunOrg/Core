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

let () = UrlClient.def_event begin fun req res -> 

  let! cuid, key, iid, instance = CClient.extract req res in 

  let  eid = req # args in
  let! entity = ohm_req_or (C404.render cuid res) $ MEntity.get_if_public eid in  

  let  tmpl = MEntity.Get.template entity in 
  let! name = ohm $ CEntityUtil.name entity in
  let! pic  = ohm $ CEntityUtil.pic_large entity in
  let! desc = ohm $ CEntityUtil.desc entity in
  let! data = ohm $ CEntityUtil.data entity in

  let render_side format = 
    Run.list_filter begin fun field -> 
      let! items = ohm $ Run.list_filter begin fun (source,kind) -> 
	let json = try List.assoc source data with Not_found -> Json.Null in
	if json = Json.Null then return None else
	  match kind with 
	    | `LongText
	    | `Text     -> return (try Some (Json.to_string json) with _ -> None)
	    | `Url      -> return (try Some (Json.to_string json) with _ -> None)
	    | `Address  -> return (try Some (Json.to_string json) with _ -> None)
	    | `Date     -> try let  date = Json.to_string json in
			       let! time = req_or (return None) $ MFmt.float_of_date date in
			       let! text = ohm $ AdLib.get (`WeekDate time) in
			       return (Some text)
	                   with _ -> return None
      end field in
      if items = [] then return None else return 
	(Some (String.concat " · " items))
    end format
  in

  let! side_when  = ohm $ render_side (PreConfig_Template.Info.eventWhen tmpl) in
  let! side_where = ohm $ render_side (PreConfig_Template.Info.eventWhere tmpl) in

  let data = object
    method navbar   = cuid, Some iid 
    method side     = [ (object
      method title = return $ Html.str "Quand ?"
      method map   = None
      method info  = side_when
    end) ; (object
      method title = return $ Html.str "Où ?"
      method map   = None
      method info  = side_where
    end) ]
    method info     = []
    method name     = name
    method instance = instance # name
    method desc     = BatOption.default "" desc
    method pic      = pic 
    method home     = Action.url UrlClient.website (instance # key) ()
  end in
 
  let html = Asset_Entity_Public.render data in
  CPageLayout.core (`Website_Event_Title (instance # name, name)) html res

end
