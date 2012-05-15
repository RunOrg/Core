(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let template = 
  OhmForm.begin_object 
    (fun ~login ~password -> (object
      method login    = login
      method password = password
    end)) 

  |> OhmForm.append (fun f login -> return $ f ~login) 
      (OhmForm.Skin.text 
	 ~label:(AdLib.get `Login_Form_Login) 
	 (fun () -> return "") 
	 (OhmForm.required (AdLib.get `Login_Form_Required)))
      
  |> OhmForm.append (fun f password -> return $ f ~password) 
      (OhmForm.Skin.password
	 ~label:(AdLib.get `Login_Form_Password)
	 (OhmForm.postpone 
	    (OhmForm.required (AdLib.get `Login_Form_Required))))

  |> OhmForm.Skin.with_ok_button ~ok:(AdLib.get `Login_Form_Submit)

let () = UrlLogin.def_post_login begin fun req res -> 

  let  fail = return res in
  let! json = req_or fail (Action.Convenience.get_json req) in
  let  src  = OhmForm.from_post_json json in 
  let  form = OhmForm.create ~template ~source:src in

  let! result = ohm $ OhmForm.result form in

  match result with 
    | Bad errors -> let  form = OhmForm.set_errors errors form in
		    let! json = ohm $ OhmForm.response form in
		    return $ Action.json json res
    | Ok result  -> let email = result # login in 		    
		    let password, field = result # password in
		    let fail = 
		      let! error = ohm $ AdLib.get `Login_Form_Error in		      
		      let  form  = OhmForm.set_errors [field, error] form in 
		      let! json  = ohm $ OhmForm.response form in 
		      return $ Action.json json res
		    in
		    let! uid  = ohm_req_or fail $ MUser.by_email email in
		    let! self = ohm_req_or fail $ MUser.knows_password password uid in
		    return res

end
