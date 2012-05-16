(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let template = 
  OhmForm.begin_object 
    (fun ~fname ~lname ~login ~password ~pass2 -> (object
      method fname    = fname
      method lname    = lname
      method login    = login
      method password = password
      method pass2    = pass2
    end)) 

  |> OhmForm.append (fun f fname -> return $ f ~fname) 
      (OhmForm.Skin.text 
	 ~label:(AdLib.get `Login_Form_Firstname) 
	 (fun () -> return "") 
	 (OhmForm.required (AdLib.get `Login_Form_Required)))

  |> OhmForm.append (fun f lname -> return $ f ~lname) 
      (OhmForm.Skin.text 
	 ~label:(AdLib.get `Login_Form_Lastname) 
	 (fun () -> return "") 
	 (OhmForm.required (AdLib.get `Login_Form_Required)))

  |> OhmForm.append (fun f login -> return $ f ~login) 
      (OhmForm.Skin.text 
	 ~label:(AdLib.get `Login_Form_Login) 
	 (fun () -> return "") 
	 (OhmForm.required (AdLib.get `Login_Form_Required)))
      
  |> OhmForm.append (fun f password -> return $ f ~password) 
      (OhmForm.Skin.password
	 ~label:(AdLib.get `Login_Form_Password)
	 (OhmForm.required (AdLib.get `Login_Form_Required)))

  |> OhmForm.append (fun f pass2 -> return $ f ~pass2) 
      (OhmForm.Skin.password
	 ~label:(AdLib.get `Login_Form_Pass2)
	 (OhmForm.postpone 
	    (OhmForm.required (AdLib.get `Login_Form_Required))))

  |> OhmForm.Skin.with_ok_button ~ok:(AdLib.get `Login_Form_Signup_Submit)

module ConfirmArgs = Fmt.Make(struct
  type json t = <
    instance : IInstance.t option ;
    path     : string list ;
    user     : IUser.t 
  >
end)

let send_signup_confirmation = 
  let task = O.async # define "login-signup-confirm" ConfirmArgs.fmt 
    begin fun arg -> 

      let! _ = ohm $ MMail.send_to_self (arg # user) 
	begin fun self user send -> 

	  return ()

	end in

      return () 

    end in
  fun ~iid ~path ~uid -> task (object
    method instance = iid
    method path     = path
    method user     = uid
  end)

let () = UrlLogin.def_post_signup begin fun req res -> 

  let  fail = return res in
  let! json = req_or fail (Action.Convenience.get_json req) in
  let  src  = OhmForm.from_post_json json in 
  let  form = OhmForm.create ~template ~source:src in

  let! result = ohm $ OhmForm.result form in

  match result with 
    | Bad errors -> let  form = OhmForm.set_errors errors form in
		    let! json = ohm $ OhmForm.response form in
		    return $ Action.json json res
    | Ok result  -> return res 

end
