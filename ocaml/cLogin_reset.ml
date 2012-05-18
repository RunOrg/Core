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

	  let  url = Action.url UrlMail.passReset () (arg # user, token) in
	  
	  let  body = Asset_Mail_PassReset.render (object
	    method url   = url 
	    method name  = user # fullname
	    method email = user # email
	  end) in
	  
	  let! from, html = ohm $ CMail.Wrap.render ?iid:(arg # instance) self body in
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
    let url  = Action.url UrlLogin.post_lost () () in

    let! html = ohm $ 
      Asset_Dialog_Dialog.render (object
	method width = "600"
	method title = AdLib.get `Login_Lost_Title
	method body  = Asset_Form_Clean.render (OhmForm.render form url)  
      end)
    in
    
    let js   = Js.stackPush ~html () in
    
    return (Action.javascript js res)

  end
