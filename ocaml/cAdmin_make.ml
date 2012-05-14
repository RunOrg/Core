(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

open FAdmin.MakeAdmin

let () = CAdmin_common.register UrlAdmin.make_admin begin fun i18n user request response ->

  let data = object
    method url  = UrlAdmin.make_admin_post # build
  end in 

  let response = 
    CAdmin_common.layout
      ~title:(View.esc "Nomination d'administrateurs")
      ~body:(VAdmin.MakeAdmin.render data i18n)
      ~js:(JsCode.seq [])
      response
  in

  return response

end

let () = CAdmin_common.register UrlAdmin.make_admin_post begin fun i18n user request response ->

  let form = Form.readpost (request # post) in

  let! (iid_opt,form) = ohm (
    Form.breathe `Instance Fmt.String.fmt MInstance.by_key
      ~error:(i18n,`text "Association non trouvée") form
  ) in

  let! (uid_opt,form) = ohm (
    Form.breathe `Email Fmt.String.fmt MUser.by_email
      ~error:(i18n,`text "Utilisateur non trouvé") form
  ) in

  let fail = return (Action.json (Form.response form) response) in

  let! iid = req_or fail iid_opt in
  let! uid = req_or fail uid_opt in
  let! aid = ohm (MAvatar.become_contact iid uid) in


  let! ()  = ohm $ MMembership.Backdoor.make_admin aid iid in 

  return 
    (Action.javascript (Js.redirect (UrlAdmin.make_admin # build)) response)

end

