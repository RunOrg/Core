(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module ConfirmArgs = Fmt.Make(struct
  type json t = <
    instance : IInstance.t option ;
    user     : IUser.t 
  >
end)

let send = 
  let task = O.async # define "login-reset" ConfirmArgs.fmt 
    begin fun arg -> 

      (* Clicking the link will confirm the account *)
      let cuid  = IUser.Assert.is_old (arg # user) in
      let token = IUser.Deduce.make_old_session_token cuid in

      let! _ = ohm $ MMail.other_send_to_self (arg # user) 
	begin fun self user send -> 

	  let  url = Action.url UrlMail.passReset (user # white) (arg # user, token) in
	  
	  let  body = Asset_Mail_PassReset.render (object
	    method url   = url 
	    method name  = user # fullname
	    method email = user # email
	  end) in
	  
	  let! from, html = ohm $ CMail.Wrap.render ?iid:(arg # instance) (user # white) self body in
	  let  subject = AdLib.get `Mail_PassReset_Title in
 
	  send ~from ~subject ~html

	end in

      return () 

    end in
  fun ~iid ~(uid:IUser.t) -> task (object
    method instance = iid
    method user     = uid
  end)

let template = 
  OhmForm.Skin.text
    ~label:(AdLib.get `Login_Form_Login)
    (fun () -> return "")
    (OhmForm.postpone
       (OhmForm.required (AdLib.get `Login_Form_Required)))

  |> OhmForm.Skin.with_ok_button ~ok:(AdLib.get `Login_Form_Reset_Submit) 

let () = UrlLogin.def_lost 
  begin fun req res -> 

    let form = OhmForm.create ~template ~source:OhmForm.empty in
    let url  = Action.url UrlLogin.post_lost (req # server) (req # args) in

    let! html = ohm $ 
      Asset_Dialog_Dialog.render (object
	method width = "600"
	method title = AdLib.get `Login_Lost_Title
	method body  = Asset_Form_Clean.render (OhmForm.Convenience.render form url)  
      end)
    in
    
    let js   = Js.stackPush ~html () in
    
    return (Action.javascript js res)

  end

let () = UrlLogin.def_post_lost 
  begin fun req res -> 

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
    
    let! email, email_field = ohm_ok_or fail $ OhmForm.result form in  

    (* Try finding an user with this email. *)
    
    let fail = 
      let! error = ohm $ AdLib.get `Login_Form_Reset_NotFound in
      let  form = OhmForm.set_errors [ email_field, error ] form in
      let! json = ohm $ OhmForm.response form in
      return $ Action.json json res 
    in

    let! uid = ohm_req_or fail $ MUser.by_email email in
    let  iid = UrlLogin.instance_of (req # args) in
    
    let! ()  = ohm $ send ~iid ~uid  in

    let! html = ohm $ 
      Asset_Dialog_Dialog.render (object
	method width = "600"
	method title = AdLib.get `Login_Lost_Title
	method body  = Asset_Login_PopReset.render email
      end)
    in
    
    let js   = Js.stackPush ~html () in        

    return $ Action.javascript js res
      
  end 

let () = UrlMail.def_passReset begin fun req res -> 

  let expired uid = 
    
    let! () = ohm $ send None uid in 
    
    let html = Asset_Login_ResetResend.render (object
      method navbar = (req # server,None,None)
      method title  = AdLib.get `Login_ResetResend_Title
    end) in

    CPageLayout.core (req # server) `Login_ResetResend_Title html res

  in

  let uid, proof = req # args in 
  
  let! cuid = req_or (expired uid) 
    (match IUser.Deduce.from_session_token proof uid with `Old cuid -> Some cuid | _ -> None) 
  in

  let! () = ohm $ MAdminLog.log 
    ~uid
    MAdminLog.Payload.LoginWithReset
  in

  let  url  = Action.url UrlMe.Account.pass (req # server) () in
  
  return $ CSession.start (`Old cuid) (Action.redirect url res)

end
