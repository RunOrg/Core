(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Admin  = CProfile_admin
module Groups = CProfile_groups
module Forms  = CProfile_forms

let () = CClient.define ~back:(Action.url UrlClient.Members.home) UrlClient.Profile.def_home begin fun access -> 

  let e404 = O.Box.fill (Asset_Client_PageNotFound.render ()) in

  let! aid = O.Box.parse IAvatar.seg in
  let! iid = ohm_req_or e404 $ O.decay (MAvatar.get_instance aid) in 
  let! ()  = true_or e404 (iid = IInstance.decay (access # iid)) in 

  let  me  = aid = IAvatar.decay (access # self) in
     
  let! content = O.Box.add begin
    
    let! seg = O.Box.parse UrlClient.Profile.tabs in 

    let menu = List.map begin fun seg' ->
      (object
	method selected = seg = seg'
	method url      = Action.url UrlClient.Profile.home (access # instance # key)
	  [IAvatar.to_string aid; fst UrlClient.Profile.tabs seg']
	method label    = seg'
       end)
    end $ BatList.filter_map identity [
      Some `Groups ;
      (if PreConfig_Vertical.profileForms (access # instance # ver) = [] then None else Some `Forms) ; 
      Some `Messages ; 
      Some `Images ; 
      Some `Files 
    ] in 

    let admin = match CAccess.admin access with 
      | None -> None
      | Some _ -> Some (Action.url UrlClient.Profile.admin (access # instance # key) 
			  [IAvatar.to_string aid])
    in

    let render body = Asset_Profile_Page_Main.render (object
      method menu = menu
      method body = body 
      method admin = admin
    end) in 

    match seg with 
      | `Groups -> Groups.body access aid me render
      | `Forms  -> Forms.body access aid me render
      | _       -> O.Box.fill $ O.decay (render (Asset_Soon_Block.render ()))

  end in 

  O.Box.fill $ O.decay begin

    let! details = ohm $ MAvatar.details aid in 
    let! pic = ohm $ CPicture.large (details # picture) in
    
    let! name = ohm begin match details # name with 
      | None -> AdLib.get `Anonymous
      | Some name -> return name
    end in 

    let! profile = ohm begin

      let! admin   = req_or (return None) (CAccess.admin access) in 
      let! uid     = req_or (return None) (details # who) in
      let  iid     = IInstance.Deduce.admin_view_profile (admin # iid) in
      let! pid     = ohm_req_or (return None) $ MProfile.find_view iid uid in 
      let! _, data = ohm_req_or (return None) $ MProfile.data pid in 

      return $ Some MProfile.Data.(object
	method email     = data.email
	method cellphone = data.cellphone
	method phone     = data.phone
      end)

    end in 

    Asset_Profile_Page.render (object
      method pic     = pic
      method name    = name
      method profile = profile
      method content = O.Box.render content 
    end)

  end
end
