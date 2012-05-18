(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Login  = CLogin_login
module Signup = CLogin_signup

let () = UrlLogin.def_login begin fun req res -> 

  let login = 
    let form = OhmForm.create ~template:Login.template ~source:OhmForm.empty in
    let url  = Action.url UrlLogin.post_login () (req # args) in
    Asset_Form_Clean.render (OhmForm.render form url)
  in 
  
  let signup = 
    let form = OhmForm.create ~template:Signup.template ~source:OhmForm.empty in
    let url  = Action.url UrlLogin.post_signup () (req # args) in
    Asset_Form_Clean.render (OhmForm.render form url)
  in

  let iid = UrlLogin.instance_of (req # args) in

  let title = 
    AdLib.get 
      (if iid = None then `Login_Heading_Core else `Login_Heading_Client)
  in

  let html = Asset_Login_Page.render (object
    method navbar = (None,iid)
    method title  = title 
    method login  = login
    method signup = signup
    method lost   = Js.remote ~url:(Action.url UrlLogin.lost () (req # args)) ()
  end) in

  CPageLayout.core `Login_Title html res

end
    
