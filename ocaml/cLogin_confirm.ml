(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let resend_confirmation = 
  O.async # define "resend-confirm" IUser.fmt
    begin fun uid -> 
      
      (* Restore new currentuser *)
      let cuid  = IUser.Assert.is_new uid in
      let token = IUser.Deduce.make_confirm_token cuid in

      let! _ = ohm $ MMail.other_send_to_self uid
	begin fun self user send -> 

	  let  url = Action.url UrlMail.signupConfirm (user # white) (uid, token) in
	  
	  let  body = Asset_Mail_SignupConfirm.render (object
	    method url   = url 
	    method name  = user # fullname
	    method email = user # email
	  end) in
	  
	  let! from, html = ohm $ CMail.Wrap.render (user # white) self body in
	  let  subject = AdLib.get `Mail_SignupConfirm_Title in
 
	  send ~from ~subject ~html

	end in

      return () 

    end 

let () = UrlMail.def_signupConfirm begin fun req res -> 

  let expired uid = 
    
    let! () = ohm $ resend_confirmation uid in 
    
    let html = Asset_Confirm_Resend.render (object
      method navbar = (req # server,None,None)
      method title  = AdLib.get `Confirm_Resend_Title
    end) in

    CPageLayout.core `Confirm_Resend_Title html res

  in

  let uid, proof = req # args in 
  
  let! cuid = req_or (expired uid) (IUser.Deduce.from_confirm_token proof uid) in
  let  uid  = IUser.Deduce.old_can_confirm cuid in 
  let!  _   = ohm $ MUser.confirm uid in 

  let  url  = Action.url UrlMe.Account.home (req # server) () in
  
  return $ CSession.start (`Old cuid) (Action.redirect url res)

end
