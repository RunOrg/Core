(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Left      = CWebsite_left

let () = UrlClient.def_calendar begin fun req res -> 

  let! cuid, key, iid, instance = CClient.extract req res in

  let! future = ohm $ MEvent.All.future iid in 
  let! list = ohm $ Run.list_filter begin fun event ->
    let  eid  = IEvent.decay $ MEvent.Get.id event in 
    let  url  = Action.url UrlClient.event key eid in 
    let! pic  = ohm $ CPicture.small_opt (MEvent.Get.picture event) in
    let! name = req_or (return None) $ MEvent.Get.name event in
    let! date = req_or (return None) $ MEvent.Get.date event in
    let  date = Date.to_timestamp date in
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

  CPageLayout.core (snd key) (`Website_Calendar_Title (instance # name)) html res

end

let () = UrlClient.def_event begin fun req res -> 

  let! cuid, key, iid, instance = CClient.extract req res in 
  let  e404 = C404.render (snd key) cuid res in

  let  eid = req # args in
  let! event = ohm_req_or e404 $ MEvent.view eid in
  let! data  = ohm_req_or e404 $ MEvent.Get.data event in

  let! pic  = ohm $ CPicture.large (MEvent.Get.picture event) in
  let! name = ohm $ MEvent.Get.fullname event in 
 
  let  page = MEvent.Data.page data in

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

  let! block_where = ohm begin
    let! address = req_or (return None) (MEvent.Data.address data) in
    return $ Some (object
      method title = AdLib.write `Website_Event_Where
      method info  = [ address ]
      method map   = let  address = Netencoding.Url.encode address in
		     Some (object (self)
		       method enlarge = "http://maps.google.fr/maps?f=q&hl=fr&q="^address
		       method iframe  = self # enlarge ^ "&hnear="^address^"&iwloc=N&t=m&output=embed&ie=UTF8"
		      end)
    end)
  end in 

  let! block_when = ohm begin 
    let! date = req_or (return None) $ MEvent.Get.date event in 
    let  time = Date.to_timestamp date in 
    let! date = ohm $ AdLib.get (`WeekDate time) in
    return $ Some (object
      method title = AdLib.write `Website_Event_When
      method map   = None
      method info  = [ date ]
    end)
  end in

  let data = object
    method navbar   = snd instance # key, cuid, Some iid 
    method side     = BatList.filter_map identity [ block_when ; block_where ]
    method name     = name
    method instance = instance # name
    method page     = MRich.OrText.to_html page
    method pic      = pic 
    method home     = Action.url UrlClient.website (instance # key) ()
    method twitter  = twitter
    method facebook = facebook
    method googleplus = googleplus
  end in
 
  let html = Asset_Event_Public.render data in
  CPageLayout.core (snd key) (`Website_Event_Title (instance # name, name)) html res

end
