(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

module Fields = FConfirm.Fields
module Form   = FConfirm.Form
  
let () = CCore.register UrlCore.setpass begin fun i18n request response ->

  let pass       = ref "" 
  and pass2      = ref ""
  in
  
  let form = Form.readpost (request # post)
    |> Form.mandatory `Pass       Fmt.String.fmt pass       (i18n,`label "login.signup-form.pass.required")
    |> Form.mandatory `Pass2      Fmt.String.fmt pass2      (i18n,`label "login.signup-form.pass2.required")
  in 
      
  if Form.not_valid form then 
    return (Action.json (Form.response form) response) 
  else if !pass <> !pass2 then
    return 
      (Action.json (Form.response (Form.error `Pass2 (i18n,`label "login.signup-form.pass2.invalid") form)) response) 
  else begin 

    let fail = return (Action.json (Form.response form) response) in
    
    let! self = CLogin_common.with_self 
      ~proof:(request # args 1) 
      ~uid:(request # args 0) 
      ~fail 
    in
    
    let! () = ohm (MUser.set_password !pass self) in

    return (
      response
      |> Action.json (Form.response form) 
      |> Action.javascript (Js.runTrigger FConfirm.trigger)
    )

  end
    
end
