(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

type t = IWhite.t option * ICurrentUser.t option * IInstance.t option 

let render ?(hidepic=false) ~public ~menu (owid,cuid,iid) = 

  let  uid      = BatOption.map IUser.Deduce.can_view cuid in
  let! user     = ohm $ Run.opt_bind MUser.get uid in
  let! instance = ohm $ Run.opt_bind MInstance.get iid in

  let  home =
    if user = None then Action.url UrlSplash.index owid []
    else Action.url UrlMe.News.home owid ()
  in

  let! account = ohm $ Run.opt_map begin fun user -> 
    let! pic = ohm $ CPicture.small_opt (user # picture) in
    return (object 
       method url    = Action.url UrlMe.Account.home owid ()
       method name   = user # fullname
       method pic    = pic
       method notif  = Action.url UrlMe.Notify.home owid ()
       method logout = Action.url UrlLogin.logout owid ()
       method unread = Action.url UrlMe.Notify.count None ()
     end)
   end user in
  
  let! instances = ohm $ Run.opt_map begin fun cuid -> 
    let! visited = ohm $ MInstance.visited ~count:5 cuid in
    Run.list_filter begin fun iid' -> 
      let! () = true_or (return None) (Some iid' <> iid) in 
      let! instance = ohm_req_or (return None) $ MInstance.get iid' in
      let! pic = ohm_req_or (return None) $ CPicture.small_opt (instance # pic) in
      let  url = Action.url UrlClient.Home.home (instance # key) [] in
      return $ Some (object
	method url = url 
	method pic = pic
      end)
    end visited 
  end cuid in

  let! asso = ohm begin match instance with None -> return None | Some instance -> 

    let  key = instance # key in
    let  url = if public || user = None then Action.url UrlClient.website key () else 
	Action.url UrlClient.Home.home key [] in

    let! pic = ohm $ CPicture.small_opt (instance # pic) in
    let  pic = BatOption.map (fun pic -> (object
      method pic = pic
      method url = url
    end)) pic in

    let menu = if not public && user = None then [] else menu key in

    let! desc = ohm begin 
      if public || user <> None then return None else
	let! iid = req_or (return None) iid in
	let! profile = ohm_req_or (return None) $ MInstance.Profile.get iid in
	return $ profile # desc
    end in
	  
    let website = 
      if public then 
	Action.url UrlClient.Home.home key []
      else
	Action.url UrlClient.website key () 	  
    in

    return $ Some (object
      method hidepic = hidepic
      method picture = pic
      method public  = public
      method url     = url
      method menu    = menu
      method desc    = None
      method name    = instance # name
      method website = website
    end)

  end in

  let admin = if BatOption.bind MAdmin.user_is_admin cuid <> None then
      Some (Action.url UrlAdmin.home None ())
    else 
      None
  in

  Asset_PageLayout_Navbar.render (object
    method logo      = (object 
      method owid = owid 
      method url  = home
    end) 
    method admin     = admin
    method public    = public
    method account   = account
    method instances = BatOption.default [] instances
    method asso      = asso
  end)

let intranet (owid,cuid,iid) = 

  let menu key = 
    List.map (fun (url,label) -> (object
      method url = url
      method sel = false 
      method label = AdLib.write label
    end)) [
      Action.url UrlClient.Home.home    key [], `PageLayout_Navbar_Home ;
      Action.url UrlClient.Members.home key [], `PageLayout_Navbar_Members ;
      Action.url UrlClient.Events.home  key [], `PageLayout_Navbar_Events ;
      Action.url UrlClient.Forums.home  key [], `PageLayout_Navbar_Forums ;
    ]
  in
  
  render ~public:false ~menu (owid,cuid,iid) 

let public_menu menu key = 
  List.map (fun (url,label,id) -> (object
    method url = url 
    method sel = id = menu
    method label = AdLib.write label 
  end)) [
    Action.url UrlClient.website  key (),   `PageLayout_Navbar_Public_Website,  `Home ;
    Action.url UrlClient.calendar key (),   `PageLayout_Navbar_Public_Calendar, `Calendar ;
    Action.url UrlClient.about    key (),   `PageLayout_Navbar_Public_About,    `About ;
    Action.url UrlClient.join     key None, `PageLayout_Navbar_Public_Join,     `Join 
  ]

let event (owid,cuid,iid) = 
  render ~public:true ~menu:(public_menu `Calendar) (owid,cuid,iid)
  
let public menu ~left ~main ~cuid instance = 

  let! pic = ohm $ CPicture.large (instance # pic) in

  let! status = ohm begin
    let! cuid = req_or (return `Contact) cuid in 
    MAvatar.status (instance # id) cuid
  end in
  
  let  edit = if status = `Admin then 
      Some (Action.url UrlClient.Website.picture (instance # key) [])
    else
      None
  in

  let navbar = 
    render ~public:true ~hidepic:true ~menu:(public_menu menu) (snd (instance # key),cuid,Some (instance # id))
  in
      
  let data = object
    method navbar = navbar
    method left   = left
    method main   = main 
    method home   = Action.url UrlClient.website (instance # key) ()
    method pic    = pic
    method edit   = edit
  end in

  Asset_PageLayout_Public.render data
