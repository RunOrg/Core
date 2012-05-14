(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

let mail_i18n = CLogin_common.mail_i18n 
      
let send_reset_mail_task = 
  Task.register "login.lost" IUser.fmt begin fun uid _ ->       
    MMail.send_to_self uid 
      begin fun uid user send ->
	let uid  = IUser.Deduce.self_can_login uid in 
	VMail.PasswordReset.send send mail_i18n 
	  (object
	    method fullname = user # fullname
	    method email    = user # email
	    method url      = UrlLogin.reset # build uid
	   end)
      end
    |> Run.map (fun success -> if success then Task.Finished uid else Task.Failed)
  end 

let send_reset_mail uid = 
  MModel.Task.call send_reset_mail_task (IUser.decay uid) |> Run.map ignore

module Fields = FLostpass.Fields
module Form   = FLostpass.Form

let () = CCore.register UrlLogin.lost begin fun i18n request response ->
  
  let login      = ref "" in
  
  let form = Form.readpost (request # post)
    |> Form.mandatory `Login      Fmt.String.fmt login      (i18n,`label "login.lost-form.login.required") 
  in 
  
  if Form.not_valid form then 
    return (Action.json (Form.response form) response) 
  else begin 

    let fail = 
      return
	(Action.json 
	   (Form.response (Form.error `Login (i18n,`label "login.lost-form.login.invalid") form)) 
	   response)
    in

    let! user = ohm_req_or fail (MUser.by_email !login) in    
    let! ()   = ohm (send_reset_mail user) in
	    
    let html  = VLogin.Lost.success ~email:(!login) ~i18n in
    let title = I18n.translate i18n (`label "login.lost-form.success.title") in

    return (
      response
      |> Action.json (Form.response form)
      |> Action.javascript (Js.Dialog.create html title)
    )
    			    
  end  

end
