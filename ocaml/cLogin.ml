(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

module Login          = CLogin_login
module Lost           = CLogin_lost
module Facebook       = CLogin_facebook
module SetPassword    = CLogin_setPassword
module Signup         = CLogin_signup
module Logout         = CLogin_logout
module Merge          = CLogin_merge
module ConfirmOrReset = CLogin_confirmOrReset

let () = CCore.register UrlLogin.index begin fun i18n request response ->

  let title = `label "login.title" in

  let! instance = ohm begin
    match CPreserve.read_preserve_cookie request with 
      | None -> return None
      | Some url -> 	
	let! iid_opt = ohm (MInstance.by_url url) in	
	match iid_opt with 
	  | None -> return None
	  | Some iid -> MInstance.get iid 
  end in

  let! white = ohm $ Run.opt_bind MWhite.get (BatOption.bind (#white) instance) in

  let runorg_name = 
    match white with 
      | None -> "RUN<strong>ORG</strong>"
      | Some white -> MWhite.name white
  in

  let body = 
    return (
      VLogin.login 
	~title 
	~runorg_name 
	~asso:(BatOption.map (#name) instance) 
	~login_init:  (FLogin.Form.empty)
	~login_url:   (UrlLogin.do_login # build)
	~signup_init: (FSignup.Form.empty)
	~signup_url:  (UrlLogin.signup # build)
	~lost_init:   (FLostpass.Form.empty)
	~lost_url:    (UrlLogin.lost # build)
	~fb_url:      (UrlLogin.facebook # build)
	~fb_channel:  (UrlLogin.fb_channel # build)
	~fb_app_id:   (MModel.Facebook.config # app_id)
	~i18n      
    )
  in

  let js_files  = ["/public/js/jquery-address.min.js"] in  

  let theme = match BatOption.map MWhite.theme white with 
    | None   -> BatOption.map (fun theme -> theme, `RunOrg) (BatOption.bind (#theme) instance)
    | Some t -> Some (t, `White) 
  in
   
  CCore.render ?theme ~js_files ~title:(return (I18n.get i18n title)) ~body response
  |> Run.map (Action.javascript (Js.onLoginPage CPreserve.fragment_cookie))

end


  
