(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Login  = CLogin_Login
module Signup = CLogin_Signup

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

  let  iid = req # args in

  let html = Asset_Login_Page.render (object
    method navbar = (None,iid)
    method login  = login
    method signup = signup
  end) in

  CPageLayout.core `Login_Title html res

end
    
