(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Login = CLogin_Login

let () = UrlLogin.def_login begin fun req res -> 

  let form = OhmForm.create ~template:Login.template ~source:OhmForm.empty in
  let url  = Action.url UrlLogin.post_login () (req # args) in
  let html = Asset_Login_Page.render 
    (Asset_Form_Clean.render (OhmForm.render form url)) in 

  CPageLayout.core `Login_Title html res

end
    
