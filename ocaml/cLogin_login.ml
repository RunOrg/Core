(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let template = 
  OhmForm.begin_object 
    (fun ~login ~password -> (object
      method login    = login
      method password = password
    end)) 

  |> OhmForm.append (fun f login -> return $ f ~login) 
      (OhmForm.Skin.text 
	 ~label:(AdLib.get `Login_Form_Login) 
	 (fun () -> return "") 
	 (OhmForm.required (AdLib.get `Login_Form_Required)))
      
  |> OhmForm.append (fun f password -> return $ f ~password) 
      (OhmForm.Skin.password
	 ~label:(AdLib.get `Login_Form_Password)
	 (OhmForm.postpone 
	    (OhmForm.required (AdLib.get `Login_Form_Required))))

  |> OhmForm.Skin.with_ok_button ~ok:(AdLib.get `Login_Form_Submit)

let attempt fail email password req res =

  let! uid  = ohm_req_or fail $ MUser.by_email email in
  let! cuid = ohm_req_or fail $ MUser.knows_password password uid in

  let res = CSession.start (`Old cuid) res in

  (* Determine the URL we should redirect to. *)

  let  iid  = UrlLogin.instance_of (req # args) in
  let  path = UrlLogin.path_of (req # args) in
  let! ins  = ohm $ Run.opt_bind MInstance.get iid in
  
  let  url  = match ins, path with 
    | None, []   -> Action.url UrlMe.News.home () ()
    | None, "me" :: path -> UrlMe.url path 
    | None, path -> Action.url UrlSplash.index () path
    | Some ins, [] -> Action.url UrlClient.Home.home (ins # key) () 
    | Some ins, path -> Action.url UrlClient.intranet (ins # key) path 
  in

  return (Action.javascript (Js.redirect ~url ()) res)

let () = UrlLogin.def_post_login begin fun req res -> 

  (* Extract the form JSON *)
  
  let  fail = return res in
  let! json = req_or fail (Action.Convenience.get_json req) in
  let  src  = OhmForm.from_post_json json in 
  let  form = OhmForm.create ~template ~source:src in

  (* Extract the result for the form (or respond with errors) *)
  
  let fail errors =
    let  form = OhmForm.set_errors errors form in
    let! json = ohm $ OhmForm.response form in
    return $ Action.json json res
  in

  let! result = ohm_ok_or fail $ OhmForm.result form in

  let email = result # login in 		    
  let password, field = result # password in

  (* Extract the user with the appropriate password, or fail *)

  let fail = 
    let! error = ohm $ AdLib.get `Login_Form_Error in		      
    let  form  = OhmForm.set_errors [field, error] form in 
    let! json  = ohm $ OhmForm.response form in 
    return $ Action.json json res
  in

  attempt fail email password req res

end
