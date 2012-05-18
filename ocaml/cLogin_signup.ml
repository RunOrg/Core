(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Login = CLogin_login

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
	 (OhmForm.postpone 
	    (OhmForm.required (AdLib.get `Login_Form_Required))))
      
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

      (* Restore new currentuser *)
      let cuid  = IUser.Assert.is_new (arg # user) in
      let token = IUser.Deduce.make_confirm_token cuid in

      let! _ = ohm $ MMail.other_send_to_self (arg # user) 
	begin fun self user send -> 

	  let  body = return (Html.str "") in
	  let! from, html = ohm $ CMail.Wrap.render ?iid:(arg # instance) self body in
	  let  subject = AdLib.get `Mail_SignupConfirm_Title in
 
	  send ~from ~subject ~html

	end in

      return () 

    end in
  fun ~iid ~path ~(cuid:[`New] ICurrentUser.id) -> task (object
    method instance = iid
    method path     = path
    method user     = IUser.Deduce.is_anyone cuid
  end)

let () = UrlLogin.def_post_signup begin fun req res -> 

  (* Extract the form JSON *)

  let  fail = return res in
  let! json = req_or fail (Action.Convenience.get_json req) in
  let  src  = OhmForm.from_post_json json in 
  let  form = OhmForm.create ~template ~source:src in

  (* Extract the result for the form *)

  let fail errors = 
    let  form = OhmForm.set_errors errors form in
    let! json = ohm $ OhmForm.response form in
    return $ Action.json json res
  in

  let! result = ohm_ok_or fail $ OhmForm.result form in  
  let  email, email_field = result # login in
  let  fname   = result # fname in
  let  lname   = result # lname in
  let  pass    = result # password in
  let  pass2, pass2_field = result # pass2 in

  (* Check that the two passwords match. *)

  let fail = 
    let! () = ohm (return ()) in
    let! error = ohm $ AdLib.get `Login_Form_Signup_Mismatch in
    let  form = OhmForm.set_errors [pass2_field, error] form in
    let! json = ohm $ OhmForm.response form in 
    return $ Action.json json res 
  in

  let! () = true_or fail (pass = pass2) in

  (* Try connecting with the password. If not, do this. *)
  
  let if_login_failed = 

    let iid  = UrlLogin.instance_of (req # args) in
    let path = UrlLogin.path_of (req # args) in

    (* Create the user. Either it's a brand new one, or the
       account already existed. *)
    let! result = ohm $ MUser.quick_create (object
      method firstname = fname
      method lastname  = lname
      method password  = pass
      method email     = email
    end) in

    match result with 
      | `created cuid -> 

	let! ( ) = ohm $ send_signup_confirmation ~iid ~path ~cuid in
	
	return res
    
      | `duplicate uid -> 
	
	return res

  in

  Login.attempt if_login_failed email pass req res

end
  

