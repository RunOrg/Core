(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

module Fields = FLogin.Fields
module Form   = FLogin.Form
  
let () = CCore.register UrlLogin.merge begin fun i18n request response ->    

  (* Step 1 : determine whether the merged-into user has logged in correctly. *)

  let login      = ref "" 
  and pass       = ref "" 
  in
  
  let form = Form.readpost (request # post) 
    |> Form.mandatory `Login      Fmt.String.fmt login      (i18n,`label "login.login-form.login.required") 
    |> Form.mandatory `Pass       Fmt.String.fmt pass       (i18n,`label "login.login-form.pass.required")
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

    let! user     = ohm_req_or fail (MUser.by_email !login) in
    let! into_uid = ohm_req_or fail (MUser.knows_password !pass user) in

    (* Step 2 : determine whether the merged user is correctly identified. *)

    let! merged_uid = CLogin_common.with_self 
      ~proof:(request # args 1) 
      ~uid:(request # args 0) 
      ~fail 
    in

    (* Step 3 : merge the users *)
    
    let! () = ohm $ MUser.merge_unconfirmed ~merged:merged_uid ~into:into_uid in

    (* Step 4 : the user has logged in, redirect to list of instances. *)

    let user = IUser.Deduce.self_can_login into_uid in 
     
    let url = 
      UrlMe.build O.Box.Seg.(root ++ CSegs.me_pages) ((),`Network) 
    in

    return (
      response 
      |> CSession.with_login_cookie user false
      |> O.Action.json (Form.response form)
      |> O.Action.javascript (Js.redirect url)
      |> CPreserve.without_preserve_cookie
    )

  end

end
