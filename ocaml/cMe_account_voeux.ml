(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CMe_common

module Parents = CMe_account_parents

let template = 

  OhmForm.begin_object
    (fun ~firstname ~initials ~body -> (object
      method firstname = firstname
      method initials  = initials
      method body      = body 
    end))

  |> OhmForm.append (fun f firstname -> return $ f ~firstname) 
      (VEliteForm.text 
	 ~label:(AdLib.get `MeAccount_Voeux_Firstname) 
	 (fun data -> return (data # firstname)) 
	 (OhmForm.required (AdLib.get `MeAccount_Voeux_Required)))
      
  |> OhmForm.append (fun f initials -> return $ f ~initials) 
      (VEliteForm.text 
	 ~label:(AdLib.get `MeAccount_Voeux_Initials) 
	 (fun data -> return (data # initials)) 
	 (OhmForm.required (AdLib.get `MeAccount_Voeux_Required)))

  |> OhmForm.append (fun f body -> return $ f ~body) 
      (VEliteForm.textarea 
	 ~label:(AdLib.get `MeAccount_Voeux_Body) 
	 (fun data -> return (data # body)) 
	 (OhmForm.required (AdLib.get `MeAccount_Voeux_Required)))               
   
  |> VEliteForm.with_ok_button ~ok:(AdLib.get `MeAccount_Voeux_Submit) 

let () = define UrlMe.Account.def_voeux begin fun owid cuid -> 

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

    let! () = ohm $ MVoeux.set uid result in 

    (* Redirect to "voeux" page *)

    let url = "http://voeux.runorg.com/2013" in
    return $ Action.javascript (Js.redirect url ()) res

  end in 

  O.Box.fill begin
    
    let  uid  = IUser.Deduce.can_view cuid in
    let! user = ohm_req_or (Asset_Me_PageNotFound.render ()) $ MUser.get uid in
    let! data = ohm $ MVoeux.get uid in

    let data = match data with 
      | Some data -> data 
      | None -> (object
	method firstname = BatOption.default "" (user # firstname)
	method initials  = BatString.head (BatOption.default "" (user # lastname)) 1
	method body      = ""
      end) 
    in

    let form = OhmForm.create ~template ~source:(OhmForm.from_seed data) in
    let url  = OhmBox.reaction_endpoint save () in

    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ] 
      method here  = parents # voeux # title
      method body  = Asset_MeAccount_Voeux.render (OhmForm.render form url)
    end)

  end
end
