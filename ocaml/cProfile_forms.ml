(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module F = MProfileForm
  
let () = CClient.define UrlClient.Profile.def_newForm begin fun access ->

  let e404 = O.Box.fill (Asset_Client_PageNotFound.render ()) in

  let! aid = O.Box.parse IAvatar.seg in
  let! iid = ohm_req_or e404 $ O.decay (MAvatar.get_instance aid) in 
  let! ()  = true_or e404 (iid = IInstance.decay (access # iid)) in 

  O.Box.fill $ O.decay begin 

    let! name = ohm $ CAvatar.name aid in 
    
    Asset_Admin_Page.render (object
      method parents = [ (object
	method title = CAvatar.name aid 
	method url   = Action.url UrlClient.Profile.home (access # instance # key) 
	  [ IAvatar.to_string aid ; fst UrlClient.Profile.tabs `Forms ]
      end) ]
      method here  = AdLib.get `Profile_Forms_Create
      method body  = return ignore
    end)

  end

end

let body access aid me = 

  let create = 
    if CAccess.admin access = None then None else 
      Some (Action.url UrlClient.Profile.newForm (access # instance # key)
	      [ IAvatar.to_string aid ] ) 
  in
  
  Asset_Profile_Forms.render (object
    method create = create
    method list = []
  end)

