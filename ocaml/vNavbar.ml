(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

type t = ICurrentUser.t option * IInstance.t option 

let render (cuid,iid) = 

  let  uid      = BatOption.map IUser.Deduce.can_view cuid in
  let! user     = ohm $ Run.opt_bind MUser.get uid in
  let! instance = ohm $ Run.opt_bind MInstance.get iid in

  let  home =
    if user = None then Action.url UrlSplash.index () []
    else Action.url UrlMe.Account.home () ()
  in

  let! account = ohm $ Run.opt_map begin fun user -> 
    let! pic = ohm $ CPicture.small (user # picture) in
    return (object 
       method url = Action.url UrlMe.Account.home () ()
       method name = user # fullname
       method pic  = pic
     end)
   end user in
  
  let! instances = ohm $ Run.opt_map begin fun cuid -> 
    let! visited = ohm $ MInstance.visited ~count:5 cuid in
    Run.list_filter begin fun iid' -> 
      let! () = true_or (return None) (Some iid' <> iid) in 
      let! instance = ohm_req_or (return None) $ MInstance.get iid' in
      let! pic = ohm_req_or (return None) $ CPicture.small_opt (instance # pic) in
      let  url = UrlClient.home (instance # key) in
      return $ Some (object
	method url = url 
	method pic = pic
      end)
    end visited 
  end cuid in

  let  menu = if user = None then None else Some (object
    method instances = List.rev $ BatOption.default [] instances
    method network   = Action.url UrlMe.Network.home () ()
    method news      = Action.url UrlMe.News.home () ()
    method logout    = Action.url UrlLogin.logout () ()
  end) in

  let! asso = ohm begin match instance with None -> return None | Some instance -> 

    let  key = instance # key in
    let  url = if user = None then Action.url UrlClient.website key [] else UrlClient.home key in

    let! pic = ohm $ Run.opt_bind (fun fid -> MFile.Url.get fid `Small) (instance # pic) in
    let  pic = BatOption.map (fun pic -> (object
      method pic = pic
      method url = url
    end)) pic in

    let menu = if user = None then None else Some (object
      method home    = UrlClient.home key
      method members = UrlClient.members key
      method forums  = UrlClient.forums key
      method events  = UrlClient.events key
    end) in

    let! desc = ohm begin 
      if user <> None then return None else
	let! iid = req_or (return None) iid in
	let! profile = ohm_req_or (return None) $ MInstance.Profile.get iid in
	return $ profile # desc
    end in
	  
    return $ Some (object
      method picture = pic
      method url     = url
      method menu    = menu
      method desc    = desc
      method name    = instance # name
      method website = Action.url UrlClient.website key [] 
    end)
  end in

  Asset_PageLayout_Navbar.render (object
    method home    = home
    method account = account
    method menu    = menu
    method asso    = asso
  end)
