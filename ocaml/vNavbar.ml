(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

type t = [`View] IUser.id option * IInstance.t option 

let render (uid,iid) = 

  let! user     = ohm $ Run.opt_bind MUser.get uid in
  let! instance = ohm $ Run.opt_bind MInstance.get iid in

  let  home = if user = None then Action.url UrlSplash.index () [] else UrlMe.Account.root in
  let  account = BatOption.map (fun user -> (object 
    method url = UrlMe.Account.root
    method name = user # fullname
  end)) user in
  
  let  menu = if user = None then None else Some (object
    method account = UrlMe.Account.root
    method network = UrlMe.Network.root
    method news    = UrlMe.News.root
    method logout  = Action.url UrlLogin.logout () ()
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
