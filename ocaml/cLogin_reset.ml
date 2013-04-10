(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Mail = MMail.Register(struct
  include (IUser : Ohm.Fmt.FMT with type t = IUser.t)
  let id = IMail.Plugin.of_string "password-reset"
  let iid _ = None
  let uid = identity 
  let from _ = None
  let solve _ = None
  let item _ = false
end)
			       
let () = Mail.define begin fun uid info -> 
  return (Some (object
    method item = None
    method act _ owid _ = return (Action.url UrlMe.Account.pass owid ())
    method mail uid u = let  title = `Mail_PassReset_Title in
			let  body  = [
			  [ `Mail_PassReset_Intro (u # fullname) ] ;
			  [ `Mail_PassReset_Explanation (u # email) ] ; 
			] in
			let button = object
			  method color = `Green
			  method url   = CMail.link (info # id) None (u # white) 
			  method label = `Mail_PassReset_Button 
			end in 
			let footer = CMail.Footer.core uid (u # white) in
			VMailBrick.render title `None body button footer
  end))
end 

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
    
    let! ()  = ohm $ Mail.send_one uid in

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

