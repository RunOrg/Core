(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CMe_common

module Parents = CMe_account_parents
module Edit    = CMe_account_edit
module Pass    = CMe_account_pass
module Picture = CMe_account_picture

module LengthSeg = OhmBox.Seg.OfJson(struct
  type json t = [ `long | `short ]
  let default = `short
end)

let render_instance user (status,iid) = 
  let! ins = ohm_req_or (return None) $ MInstance.get iid in
  let! pic = ohm $ CPicture.small_opt (ins # pic) in
  let! status = req_or (return None) begin match status with 
    | `Token -> Some (`Member (user # gender))
    | `Admin -> Some (`Admin (user # gender)) 
    | `Contact -> None
  end in
  return $ Some (object
    method pic    = pic
    method name   = ins # name
    method status = status
    method url    = UrlClient.home (ins # key) 
  end)
  
let long_user_instances user cuid = 

  let max_items = 150 in

  let  uid = IUser.Deduce.can_view_inst cuid in
  let  count     = max_items in
  let! admin_of  = ohm $ MAvatar.user_instances ~count ~status:`Admin uid in
  let  count     = max_items - List.length admin_of in
  let! member_of = ohm $ MAvatar.user_instances ~count ~status:`Token uid in

  let  list = admin_of @ member_of in
  let! list = ohm $ Run.list_filter (render_instance user) list in

  let! count = ohm $ MAvatar.count_user_instances uid in

  if list <> [] then 
    return $ Some (object
      method list  = list
      method count = count
      method more  = None
    end)
  else
    return None

let short_user_instances user cuid more = 
  
  let! list = ohm $ MInstance.visited ~count:4 cuid in 
  let! list = ohm $ Run.list_filter begin fun iid -> 
    let! status = ohm $ MAvatar.status iid cuid in
    render_instance user (status,iid)
  end list in

  let uid = IUser.Deduce.can_view_inst cuid in
  let! count = ohm $ MAvatar.count_user_instances uid in

  if list <> [] then 
    return $ Some (object
      method list  = list
      method count = count
      method more  = if count <> List.length list then Some more else None
    end)
  else
    long_user_instances user cuid 

let () = define UrlMe.Account.def_home begin fun cuid  ->   

  let  uid  = IUser.Deduce.can_view cuid in
  let! user = ohm_req_or (O.Box.fill (Asset_Me_PageNotFound.render ())) $ MUser.get uid in
 
  let! instances = O.Box.add begin
    let! seg = O.Box.parse LengthSeg.seg in
    O.Box.fill begin
      let! instances = ohm begin match seg with 
	| `short -> let! more = ohm $ O.Box.url [ fst LengthSeg.seg `long ] in 
		    short_user_instances user cuid more
	| `long  ->  long_user_instances user cuid
      end in
      Asset_MeAccount_Page_Instances.render (object
	method instances = instances
      end) 
    end
  end in

  O.Box.fill begin
    
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
    
    let data = object
      method picedit   = Action.url UrlMe.Account.picture () ()
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
	method img      = VIcon.Large.user_silhouette
	method url      = Action.url UrlMe.Account.picture () () 
	method title    = AdLib.get `MeAccount_Admin_Picture_Link
	method subtitle = Some (AdLib.get `MeAccount_Admin_Picture_Sub)
       end) ;
      
    ] in
    
    Asset_Admin_Page.render (object
      method parents = [ Parents.home ] 
      method here  = Parents.admin # title
      method body  = choices
    end)

  end
end

