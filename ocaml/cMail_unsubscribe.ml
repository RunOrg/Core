(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Wrap = CMail_wrap

module ConfirmArgs = Fmt.Make(struct
  type json t = <
    instance : IInstance.t option ;
    user     : IUser.t 
  >
end)

let send_unsubscribe_confirmation = 
  let task = O.async # define "unsubscribe-confirm" ConfirmArgs.fmt 
    begin fun arg -> 

      let! _ = ohm $ MMail.other_send_to_self (arg # user) 
	begin fun self user send -> 

	  let  token = IUser.Deduce.make_unsub_token self in
	  let  url = Action.url UrlMail.post_unsubscribe (user # white) (arg # user, token, arg # instance) in
	  
	  let  body = Asset_Mail_Unsubscribe.render (object
	    method url   = url 
	    method name  = user # fullname
	    method email = user # email
	  end) in
	  
	  let! from, html = ohm $ Wrap.render ?iid:(arg # instance) (user # white) self body in
	  let  subject = AdLib.get `Mail_Unsubscribe_Title in
 
	  send ~from ~subject ~html

	end in

      return () 

    end in
  fun ~iid ~uid -> task (object
    method instance = iid
    method user     = uid
  end)

let () = UrlMail.def_unsubscribe begin fun req res -> 

  let uid, iid = req # args in

  let title = AdLib.get `Unsubscribe_Send_Title in

  let html = Asset_Unsubscribe_Send.render (object
    method navbar = (req # server, None, iid)
    method title  = title 
  end) in

  let! () = ohm $ send_unsubscribe_confirmation ~iid ~uid in

  CPageLayout.core `Unsubscribe_Send_Title html res

end

let () = UrlMail.def_post_unsubscribe begin fun req res -> 
  
  let uid, token, iid = req # args in
  let fail = return $ Action.redirect 
    (Action.url UrlMail.unsubscribe (req # server) (uid,iid)) res in

  let! uid = req_or fail $ IUser.Deduce.from_unsub_token token uid in
  
  let! result = ohm $ MUser.obliterate uid in

  let title, html = 
    match result with 
      | `ok        -> `Unsubscribe_Confirm_Title,   Asset_Unsubscribe_Confirm.render 
      | `destroyed -> `Unsubscribe_Destroyed_Title, Asset_Unsubscribe_Destroyed.render  
      | `missing   -> `Unsubscribe_Missing_Title,   Asset_Unsubscribe_Missing.render  
  in

  let html = html (object
    method navbar = (req # server, None,iid)
    method title  = AdLib.get title 
  end) in

  CPageLayout.core title html res
	  
end
