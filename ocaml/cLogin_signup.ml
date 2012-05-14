(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

(* Signup Form ----------------------------------------------------------------- *)

let mail_i18n = CLogin_common.mail_i18n

let send_confirm_mail_task =
  Task.register "login.signup" IUser.fmt begin fun uid _ ->
    MMail.send_to_self uid
      begin fun uid user send ->
	let uid  = IUser.Deduce.self_can_login uid in 
	VMail.SignupConfirm.send send mail_i18n 
	  (object
	    method fullname = user # fullname
	    method email    = user # email
	    method url      = UrlLogin.confirm # build uid
	   end)
      end 
    |> Run.map (fun success -> if success then Task.Finished uid else Task.Failed)
  end  

let send_confirm_mail uid = 
  MModel.Task.call send_confirm_mail_task (IUser.decay uid) |> Run.map ignore

module Fields = FSignup.Fields
module Form   = FSignup.Form

let () = CCore.register UrlLogin.signup begin fun i18n request response ->

  let login      = ref "" 
  and pass       = ref "" 
  and pass2      = ref ""
  and firstname  = ref "" 	
  and lastname   = ref ""
  and accept     = ref false
  in
  
  let form = Form.readpost (request # post)
    |> Form.mandatory `Login      Fmt.String.fmt login      (i18n,`label "login.signup-form.login.required") 
    |> Form.mandatory `Pass       Fmt.String.fmt pass       (i18n,`label "login.signup-form.pass.required")
    |> Form.mandatory `Pass2      Fmt.String.fmt pass2      (i18n,`label "login.signup-form.pass2.required")
    |> Form.mandatory `Firstname  Fmt.String.fmt firstname  (i18n,`label "login.signup-form.firstname.required")
    |> Form.mandatory `Lastname   Fmt.String.fmt lastname   (i18n,`label "login.signup-form.lastname.required")
    |> Form.mandatory `Accept     Fmt.Bool.fmt   accept     (i18n,`label "login.signup-form.accept.required") 
  in 

  let form =
    if !accept then form else 
      Form.error `Accept (i18n,`label "login.signup-form.accept.required") form
  in

  if Form.not_valid form then 
    return (Action.json (Form.response form) response) 
  else if !pass <> !pass2 then
    return 
      (Action.json (Form.response (Form.error `Pass2 (i18n,`label "login.signup-form.pass2.invalid") form)) response) 
  else begin 
    
    let details = object
      method firstname = !firstname
      method lastname  = !lastname
      method email     = !login
      method password  = !pass
    end in

    let! result = ohm (MUser.quick_create details) in

    match result with 
      | `created id -> 
	    
	let! () = ohm (send_confirm_mail id) in
	  
	let html = VLogin.Signup.success ~email:(!login) ~i18n in
	let title = I18n.translate i18n (`label "login.signup-form.success.title") in
	
	return (
	  response
	  |> Action.json (Form.response form)	  
  	  |> Action.javascript (Js.Dialog.create html title) 
	)

      | `duplicate id -> 
	    
        (* Creation failed because a confirmed user already exists with this email *)
	
	let! () = ohm (CLogin_lost.send_reset_mail id) in
	    
	let html = VLogin.Signup.taken ~email:(!login) ~i18n in
	let title = I18n.translate i18n (`label "login.signup-form.taken.title") in
	
	return (
  	  response
	  |> Action.javascript (Js.Dialog.create html title) 
	)

      | `error -> 
	  
	return (
	  response
   	  |> Action.javascript (Js.message (I18n.get i18n (`label "view.error")))
	)

  end

end
