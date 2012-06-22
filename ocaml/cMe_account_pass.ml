(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CMe_common

module Parents = CMe_account_parents

let template = 

  OhmForm.begin_object
    (fun ~pass ~pass2 -> (object
      method pass  = pass
      method pass2 = pass2
    end))

  |> OhmForm.append (fun f pass -> return $ f ~pass) 
      (OhmForm.Skin.password
	 ~label:(AdLib.get `MeAccount_Pass_Password) 
	 (OhmForm.required (AdLib.get `MeAccount_Pass_Required)))

  |> OhmForm.append (fun f pass2 -> return $ f ~pass2) 
      (OhmForm.Skin.password 
	 ~label:(AdLib.get `MeAccount_Pass_Pass2) 
	 (OhmForm.postpone 
	    (OhmForm.required (AdLib.get `MeAccount_Pass_Required))))	  
	  
  |> OhmForm.Skin.with_ok_button ~ok:(AdLib.get `MeAccount_Pass_Submit) 



let () = define UrlMe.Account.def_pass begin fun cuid -> 

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
    let  pass               = result # pass in
    let  pass2, pass2_field = result # pass2 in
    
    (* Check that the two passwords match. *)
    
    let fail = 
      let! () = ohm (return ()) in
      let! error = ohm $ AdLib.get `MeAccount_Pass_Mismatch in
      let  form = OhmForm.set_errors [pass2_field, error] form in
      let! json = ohm $ OhmForm.response form in 
      return $ Action.json json res 
    in
    
    let! () = true_or fail (pass = pass2) in
        
    (* Save the new password to the database *)
    
    let! () = ohm $ O.decay (MUser.set_password pass cuid) in 
      
    (* Redirect to home *)
      
    let url = Parents.home # url in 
    return $ Action.javascript (Js.redirect url ()) res
	
  end in 

  O.Box.fill begin
    
    let form = OhmForm.create ~template ~source:(OhmForm.from_seed ()) in
    let url  = OhmBox.reaction_endpoint save () in

    Asset_Admin_Page.render (object
      method parents = [ Parents.home ; Parents.admin ] 
      method here  = Parents.pass # title
      method body  = Asset_Form_Clean.render (OhmForm.render form url)
    end)

  end
end
