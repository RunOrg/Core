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
  
  let main = Asset_Website_Calendar.render list in

  let left = Left.render ~calendar:false cuid key iid in 
  let html = VNavbar.public `Calendar ~cuid ~left ~main instance in

  CPageLayout.core (`Website_Calendar_Title (instance # name)) html res

end

let () = UrlClient.def_event begin fun req res -> 

  let! cuid, key, iid, instance = CClient.extract req res in 

  let  eid = req # args in
  let! entity = ohm_req_or (C404.render (snd key) cuid res) $ MEntity.get_if_public eid in  

  let  tmpl = MEntity.Get.template entity in 
  let! name = ohm $ CEntityUtil.name entity in
  let! pic  = ohm $ CEntityUtil.pic_large entity in
  let! desc = ohm $ CEntityUtil.desc entity in
  let! data = ohm $ CEntityUtil.data entity in

  let render_fields fields = 
    Run.list_filter begin fun (source,kind) -> 
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
    end fields
  in

  let render_side format = 
    Run.list_filter begin fun item -> 
      let! fields = ohm $ render_fields item in
      if fields = [] then return None else return 
	(Some (String.concat " · " fields))
    end format
  in

  let render_info format = 
    Run.list_filter begin fun (label,items) -> 
      let! items = ohm $ Run.list_filter begin fun (labelopt,fields) -> 
	let! fields = ohm $ render_fields fields in
	if fields = [] then return None else return 
	  (Some (object
	    method label = BatOption.map AdLib.write labelopt 
	    method data  = String.concat " · " fields
	  end))
      end items in
      return (if items = [] then None else Some (object
	method title = AdLib.write label
	method items = items
      end))
    end format
  in    

  let! side_when  = ohm $ render_side (PreConfig_Template.Info.eventWhen tmpl) in
  let! side_where = ohm $ render_side (PreConfig_Template.Info.eventWhere tmpl) in

  let! info = ohm $ render_info (PreConfig_Template.Info.rest tmpl) in

  let url = Action.url UrlClient.event (req # server) (req # args) in
  let parent = Action.url UrlClient.website (req # server) () in
  let twitter = 
    "http://platform.twitter.com/widgets/tweet_button.html?count=vertical&size=small&url="
    ^ Netencoding.Url.encode url 
  and facebook = 
    "http://www.facebook.com/plugins/like.php?href="
    ^ Netencoding.Url.encode url 
    ^ "&send=false&layout=box_count&width=70&show_faces=false&action=like&colorscheme=light&height=65"
  and googleplus = 
    "https://plusone.google.com/_/+1/fastbutton?bsv=pr&url="
    ^ Netencoding.Url.encode url 
    ^ "&parent="
    ^ Netencoding.Url.encode parent
    ^ "&size=tall&count=true&hl=en-US&jsh=m%3B%2F_%2Fapps-static%2F_%2Fjs%2Fgapi%2F__features__%2Frt%3Dj%2Fver%3DEnTGPTISmWk.fr.%2Fsv%3D1%2Fam%3D!PemfnfjrL2yI81ARQg%2Fd%3D1%2Frs%3DAItRSTOVJ7YMlvCOv0BPtI0JpvYXm1nDxw#_methods=onPlusOne%2C_ready%2C_close%2C_open%2C_resizeMe%2C_renderstart"
  in

  let! map = ohm begin
    let! loc  = req_or (return None) (PreConfig_Template.Meaning.location tmpl) in 
    let! addr = req_or (return None) 
      (try Some (Json.to_string (List.assoc loc data)) with _ -> None) in
    let  addr = Netencoding.Url.encode addr in
    return $ Some (object (self)
      method enlarge = "http://maps.google.fr/maps?f=q&hl=fr&q="^addr
      method iframe  = self # enlarge ^ "&hnear="^addr^"&iwloc=N&t=m&output=embed&ie=UTF8"
    end)
  end in 

  let data = object
    method navbar   = snd instance # key, cuid, Some iid 
    method side     = List.filter (#info|-(<>)[]) [ (object
      method title = AdLib.write `Website_Event_When
      method map   = None
      method info  = side_when
    end) ; (object
      method title = AdLib.write `Website_Event_Where
      method map   = map
      method info  = side_where
    end) ]
    method info     = []
    method name     = name
    method instance = instance # name
    method desc     = BatOption.default "" desc
    method pic      = pic 
    method home     = Action.url UrlClient.website (instance # key) ()
    method twitter  = twitter
    method facebook = facebook
    method googleplus = googleplus
 end in
 
  let html = Asset_Entity_Public.render data in
  CPageLayout.core (`Website_Event_Title (instance # name, name)) html res

end
