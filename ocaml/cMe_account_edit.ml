(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CMe_common

module Parents = CMe_account_parents

module GenderFmt = Fmt.Make(struct
  type json t = [ `m | `f ]
end)

let template = 

  OhmForm.begin_object
    (fun ~info ~contact -> (object
      method info = info
      method contact = contact
    end))

  |> OhmForm.append (fun f info -> return $ f ~info) 
      (OhmForm.wrap ".joy-fields" 
	 (Asset_Form_Section.render (AdLib.get `MeAccount_Edit_AboutYou))
	 begin
	   OhmForm.begin_object
	     (fun ~fname ~lname ~birthdate ~gender -> (object
	       method firstname = fname
	       method lastname  = lname
	       method birthdate = birthdate
	       method gender    = gender
	     end))
	     
	   |> OhmForm.append (fun f fname -> return $ f ~fname) 
	       (OhmForm.Skin.text 
		  ~label:(AdLib.get `MeAccount_Edit_Firstname) 
		  (fun user -> return $ BatOption.default "" (user # firstname)) 
		  (OhmForm.required (AdLib.get `MeAccount_Edit_Required)))
	       
	   |> OhmForm.append (fun f lname -> return $ f ~lname) 
	       (OhmForm.Skin.text 
		  ~label:(AdLib.get `MeAccount_Edit_Lastname) 
		  (fun user -> return $ BatOption.default "" (user # lastname)) 
		  (OhmForm.required (AdLib.get `MeAccount_Edit_Required)))
	       
	   |> OhmForm.append (fun f birthdate -> return $ f ~birthdate) 
	       (OhmForm.Skin.text 
		  ~label:(AdLib.get `MeAccount_Edit_Birthdate) 
		  begin fun user -> 
		    let date = BatOption.bind MFmt.dmy_of_date (user # birthdate) in
		    let date = BatOption.map (fun (d,m,y) -> Printf.sprintf "%02d / %02d / %04d" d m y) date in
		    return $ BatOption.default "" date
		  end
		  begin fun field string -> 
		    let string = BatString.trim string in 
		    if string = "" then return (Ok None) else
		      try let date = Scanf.sscanf string "%u / %u / %u" MFmt.date_of_dmy in
			  return (Ok (Some date))
		      with _ -> let! error = ohm $ AdLib.get `MeAccount_Edit_DateError in
				return (Bad (field,error))
		  end)

	   |> OhmForm.append (fun f gender -> return $ f ~gender) 
	       (OhmForm.Skin.radio
		  ~horizontal:true
		  ~label:(AdLib.get `MeAccount_Edit_Gender)
		  ~format:GenderFmt.fmt
		  ~source:[ `f, (AdLib.write `MeAccount_Edit_Female) ;
			    `m, (AdLib.write `MeAccount_Edit_Male) ]
		  (fun user -> return $ user # gender)
		  OhmForm.keep)
	 end)
      
  |> OhmForm.append (fun f contact -> return $ f ~contact) 
      (OhmForm.wrap ".joy-fields" 
	 (Asset_Form_Section.render (AdLib.get `MeAccount_Edit_Contact))
	 begin
	   OhmForm.begin_object (fun ~phone ~cellphone ~address ~city ~zipcode ~country -> (object
	     method phone     = phone
	     method cellphone = cellphone
	     method address   = address
	     method city      = city
	     method zipcode   = zipcode
	     method country   = country 
	   end))
	     
	   |> OhmForm.append (fun f phone -> return $ f ~phone) 
	       (OhmForm.Skin.text 
		  ~label:(AdLib.get `MeAccount_Edit_Phone) 
		  (fun user -> return $ BatOption.default "" (user # phone)) 
		  (OhmForm.keep))
	       
	   |> OhmForm.append (fun f cellphone -> return $ f ~cellphone) 
	       (OhmForm.Skin.text 
		  ~label:(AdLib.get `MeAccount_Edit_Cellphone) 
		  (fun user -> return $ BatOption.default "" (user # cellphone)) 
		  (OhmForm.keep))
	       
	   |> OhmForm.append (fun f address -> return $ f ~address) 
	       (OhmForm.Skin.text 
		  ~label:(AdLib.get `MeAccount_Edit_Address) 
		  (fun user -> return $ BatOption.default "" (user # address)) 
		  (OhmForm.keep))
	       
	   |> OhmForm.append (fun f city -> return $ f ~city) 
	       (OhmForm.Skin.text 
		  ~label:(AdLib.get `MeAccount_Edit_City) 
		  (fun user -> return $ BatOption.default "" (user # city)) 
		  (OhmForm.keep))
	       
	   |> OhmForm.append (fun f zipcode -> return $ f ~zipcode) 
	       (OhmForm.Skin.text 
		  ~label:(AdLib.get `MeAccount_Edit_Zipcode) 
		  (fun user -> return $ BatOption.default "" (user # zipcode)) 
		  (OhmForm.keep))
	       
	   |> OhmForm.append (fun f country -> return $ f ~country) 
	       (OhmForm.Skin.text 
		  ~label:(AdLib.get `MeAccount_Edit_Country) 
		  (fun user -> return $ BatOption.default "" (user # country)) 
		  (OhmForm.keep))
	 end)
      
  |> OhmForm.Skin.with_ok_button ~ok:(AdLib.get `MeAccount_Edit_Submit) 

let () = define UrlMe.Account.def_edit begin fun owid cuid -> 

  let parents = Parents.make owid in 

  let  uid  = IUser.Deduce.can_edit cuid in
  let! save = O.Box.react Fmt.Unit.fmt begin fun () json _ res -> 

    let  src  = OhmForm.from_post_json json in 
    let  form = OhmForm.create ~template ~source:src in
        
    (* Extract the result for the form *)
    
    let fail errors = 
      let  form = OhmForm.set_errors errors form in
      let! json = ohm $ OhmForm.response form in
      return $ Action.json json res
    in
    
    let! result = ohm_ok_or fail $ OhmForm.result form in  

    (* Save the changes to the database *)

    let not_empty = function
      | ""  -> None
      | str -> Some str
    in

    let! () = ohm $ O.decay (MUser.update uid (object
      method firstname = result # info # firstname
      method lastname  = result # info # lastname
      method birthdate = result # info # birthdate
      method phone     = not_empty result # contact # phone
      method cellphone = not_empty result # contact # cellphone
      method address   = not_empty result # contact # address
      method zipcode   = not_empty result # contact # zipcode
      method city      = not_empty result # contact # city
      method country   = not_empty result # contact # country
      method gender    = result # info # gender
    end)) in

    (* Redirect to main page *)

    let url = parents # home # url in 
    return $ Action.javascript (Js.redirect url ()) res

  end in 

  O.Box.fill begin
    
    let  uid  = IUser.Deduce.can_view cuid in
    let! user = ohm_req_or (Asset_Me_PageNotFound.render ()) $ MUser.get uid in

    let form = OhmForm.create ~template ~source:(OhmForm.from_seed user) in
    let url  = OhmBox.reaction_endpoint save () in

    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ] 
      method here  = parents # edit # title
      method body  = Asset_Form_Clean.render (OhmForm.render form url)
    end)

  end
end
