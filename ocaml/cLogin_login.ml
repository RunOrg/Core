(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

module Fields = FLogin.Fields
module Form   = FLogin.Form
  
let () = CCore.register UrlLogin.do_login begin fun i18n request response ->    

  let login      = ref "" 
  and pass       = ref "" 
  and rememberMe = ref false
  in
  
  let form = Form.readpost (request # post) 
    |> Form.mandatory `Login      Fmt.String.fmt login      (i18n,`label "login.login-form.login.required") 
    |> Form.mandatory `Pass       Fmt.String.fmt pass       (i18n,`label "login.login-form.pass.required")
    |> Form.mandatory `RememberMe Fmt.Bool.fmt   rememberMe (i18n,`label "assert-false")
  in 
  
  if Form.not_valid form then
    return (O.Action.json (Form.response form) response) 
  else begin
      
    let fail = 
      return
	(O.Action.json 
	   (Form.response (Form.error `Login (i18n,`label "login.login-form.login.invalid") form)) 
	   response)
    in

    let! user = ohm_req_or fail (MUser.by_email !login) in
    let! ok   = ohm_req_or fail (MUser.knows_password !pass user) in

    let user = IUser.Deduce.self_can_login ok in 

    let! _ = ohm $ MNews.FromLogin.create (`Login (IUser.decay user)) in
     
    let default_url = 
      UrlMe.build O.Box.Seg.(root ++ CSegs.me_pages) ((),`News) 
    in
    
    let url = CPreserve.read_preserve_cookie request |> BatOption.default default_url in
    
    return (
      response 
      |> CSession.with_login_cookie user !rememberMe 
      |> O.Action.json (Form.response form)
      |> O.Action.javascript (Js.redirect url)
      |> CPreserve.without_preserve_cookie
    )

  end

end
