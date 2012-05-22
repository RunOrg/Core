(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CMe_common

module Parents = CMe_account_parents
module Edit    = CMe_account_edit
module Pass    = CMe_account_pass

let user_instances user cuid = 

  let max_items = 10 in

  let  uid = IUser.Deduce.can_view_inst cuid in
  let  count     = max_items in
  let! admin_of  = ohm $ MAvatar.user_instances ~count ~status:`Admin uid in
  let  count     = max_items - List.length admin_of in
  let! member_of = ohm $ MAvatar.user_instances ~count ~status:`Token uid in

  let  list = admin_of @ member_of in
  let! list = ohm $ Run.list_filter begin fun (status,iid) -> 
    let! ins = ohm_req_or (return None) $ MInstance.get iid in
    let! pic = ohm $ CPicture.small_opt (ins # pic) in
    let status = match status with 
      | `Token -> `Member (user # gender)
      | `Admin -> `Admin (user # gender) 
      | `Contact -> `Visitor (user # gender)
    in 
    return $ Some (object
      method pic    = pic
      method name   = ins # name
      method status = status
      method url    = "" 
    end)
  end list in

  if list <> [] then 
    return $ Some (object
      method list  = list
      method count = List.length list
    end)
  else
    return None

let () = define UrlMe.Account.def_home begin fun cuid  ->   
  O.Box.fill begin

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
      [ `MeAccount_Detail_Phone,                     user # phone ;
	`MeAccount_Detail_Cellphone,                 user # cellphone ;
	`MeAccount_Detail_Birthdate (user # gender), birthdate ;
	`MeAccount_Detail_Address,                   user # address ;
	`MeAccount_Detail_Zipcode,                   user # zipcode ;
	`MeAccount_Detail_Country,                   user # country ;
	`MeAccount_Detail_Gender,                    Some gender
      ]
    in

    let! instances = ohm $ user_instances user cuid in 
    
    let data = object
      method url       = pic 
      method fullname  = user # fullname
      method details   = details
      method email     = user # email
      method edit      = Action.url UrlMe.Account.admin () ()
      method instances = instances
    end in
    
    Asset_MeAccount_Page.render data

  end 
end

let () = define UrlMe.Account.def_admin begin fun cuid -> 
  O.Box.fill begin 
    
    let choices = Asset_Admin_Choice.render [
      
      (object
	method img      = VIcon.Large.vcard
	method url      = Action.url UrlMe.Account.edit () ()
	method title    = AdLib.get `MeAccount_Admin_Edit_Link
	method subtitle = Some (AdLib.get `MeAccount_Admin_Edit_Sub)
       end) ;
      
      (object
	method img      = VIcon.Large.key
	method url      = Action.url UrlMe.Account.pass () ()
	method title    = AdLib.get `MeAccount_Admin_Pass_Link
	method subtitle = Some (AdLib.get `MeAccount_Admin_Pass_Sub)
       end) ;
      
      (object
	method img      = VIcon.Large.lock
	method url      = Action.url UrlMe.Account.privacy () () 
	method title    = AdLib.get `MeAccount_Admin_Privacy_Link
	method subtitle = Some (AdLib.get `MeAccount_Admin_Privacy_Sub)
       end) ;
      
    ] in
    
    Asset_Admin_Page.render (object
      method parents = [ Parents.home ] 
      method here  = Parents.admin # title
      method body  = choices
    end)

  end
end

