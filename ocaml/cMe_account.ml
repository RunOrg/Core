(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CMe_common

let () = UrlMe.Account.def_home $ action begin fun cuid req res -> 
  
  let body = O.Box.fill begin
    let  uid  = IUser.Deduce.can_view cuid in
    let! user = ohm_req_or (Asset_Me_PageNotFound.render ()) $ MUser.get uid in
    
    let! pic  = ohm $ CPicture.large (user # picture) in
    
    let! gender = ohm $ AdLib.get (`Gender (user # gender)) in
    let  birthdate = BatOption.bind MFmt.float_of_date (user # birthdate) in
    let! birthdate = ohm $ Run.opt_map (fun d -> AdLib.get (`Date d)) birthdate in

    let details = BatList.filter_map 
      (function
	| _, None   -> None
	| key, Some value -> Some (object
	  method key = key
	  method value = value
	end))
      [ `MeAccount_Detail_Phone, user # phone ;
	`MeAccount_Detail_Cellphone, user # cellphone ;
	`MeAccount_Detail_Birthdate (user # gender), birthdate ;
	`MeAccount_Detail_Address, user # address ;
	`MeAccount_Detail_Zipcode, user # zipcode ;
	`MeAccount_Detail_Country, user # country ;
	`MeAccount_Detail_Gender, Some gender
      ]
    in
    
    let data = object
      method url      = pic 
      method fullname = user # fullname
      method details  = details
      method email    = user # email
      method edit     = Action.url UrlMe.Account.edit () ()
    end in
    
    Asset_MeAccount_Page.render data
  end in

  O.Box.response ~prefix:"/account" ~parents:[] 
    O.BoxCtx.make body req res 

end

let () = UrlMe.Account.def_edit $ action begin fun cuid req res -> 

  let back    = Action.url UrlMe.Account.home () () in

  let choices = Asset_Admin_Choice.render [

    (object
      method img      = VIcon.Large.vcard
      method url      = "" 
      method title    = return "Compléter mon profil"
      method subtitle = Some (return "Remplissez les informations de votre compte")
     end) ;

    (object
      method img      = VIcon.Large.key
      method url      = "" 
      method title    = return "Changer mon mot de passe"
      method subtitle = Some (return "Entrez un nouveau mot de passe pour vous connecter")
     end) ;

    (object
      method img      = VIcon.Large.lock
      method url      = "" 
      method title    = return "Options de partage"
      method subtitle = Some (return "Définissez quelles informations sont visibles et par qui")
     end) ;
	
  ] in

  let body = O.Box.fill begin 
    Asset_Admin_Page.render (object
      method parents = [
	(object
	  method title = AdLib.get `MeAccount_Page_Title
	  method url  = back
	 end)
      ]
      method here  = AdLib.get `MeAccount_Admin_Title
      method body  = choices
    end)
  end in

  O.Box.response ~prefix:"/edit-account" ~parents:["/account"]
    O.BoxCtx.make body req res
      
end
