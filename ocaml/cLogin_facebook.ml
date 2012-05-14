(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

let () = CCore.register UrlLogin.fb_channel begin fun i18n request response -> 

  let html = "<script src=\"//connect.facebook.net/en_US/all.js\"></script>" in

  return (Action.html (fun _ -> View.str html) response) 

end

let () = CCore.register UrlLogin.fb_confirm begin fun i18n request response ->
  
  let fail = 
    let html  = VLogin.Facebook.not_found ~i18n
    and title = I18n.translate i18n (`label "login.facebook.not_found") in
    return (Action.javascript (Js.Dialog.create html title) response)
  in

  let success user = 
    return (
      response
      |> CSession.with_login_cookie user false 
      |> Action.javascript Js.refresh
      |> CPreserve.without_preserve_cookie
    )
  in

  (* Extract the facebook session *)

  let! session = req_or fail
    (OhmFacebook.get_session MModel.Facebook.config request) in
      
  let! details = req_or fail begin
    match OhmFacebook.get session with 
      | `valid details -> Some details	
      | `invalid -> None	    
      | `not_found -> None
  end in

  (* Extract the user we are binding *)

  let panic = return (Action.javascript Js.panic response) in

  let! uid   = req_or panic (request # args 0) in
  let! proof = req_or panic (request # args 1) in
  let! uid   = req_or panic (IUser.Deduce.from_confirm_token proof (IUser.of_string uid)) in 
  
  (* Attempt to bind the user *)

  let! ok = ohm (MUser.facebook_bind uid (session # uid) details) in  
  
  if ok then 
    (* We control the connected facebook session *)
    success (uid |> IUser.Assert.is_self |> IUser.Deduce.self_can_login) 
  else begin 

    let uid = IUser.Deduce.can_view uid in 
    let! user_data = ohm_req_or panic (MUser.get uid) in

    let html  =
      VLogin.Facebook.Taken.render (object
	method their_email = details # email
	method my_email = user_data # email
	method login_url = UrlLogin.index # build
      end) i18n
    in

    let  title = I18n.translate i18n (`label "login.facebook.already_taken") in

    return (Action.javascript (Js.Dialog.create html title) response)
        
  end

end

let confirm success i18n request response = 

  let fail = 
    let html  = VLogin.Facebook.not_found ~i18n
    and title = I18n.translate i18n (`label "login.facebook.not_found") in
    return (Action.javascript (Js.Dialog.create html title) response)
  in

  let! session = req_or fail
    (OhmFacebook.get_session MModel.Facebook.config request) in
  
  let! user_opt = ohm (MUser.by_facebook (session # uid)) in  
  
  match user_opt with 
    | Some user -> 	    	      
      
      let user : [`CanLogin] IUser.id = 
	user
	(* We hold the facebook session : we are the user. *)
        |> IUser.Assert.is_self
	|> IUser.Deduce.self_can_login
      in
      
      success user
	
    | None -> 
      
      match OhmFacebook.get session with 
	| `valid details ->		
	  
	  let! user = ohm_req_or fail
	    (MUser.facebook_create (session # uid) details) in

	  let user = 
	    (* We just connected the account : we are this person. *)
	    IUser.Assert.is_self user |> IUser.Deduce.self_can_login
	  in

	  success user
	    
	| `invalid -> 		
	  
	  let html  = VLogin.Facebook.invalid ~i18n in
	  let title = I18n.translate i18n (`label "login.facebook.invalid") in
	  
	  return (Action.javascript (Js.Dialog.create html title) response)
	    
	| `not_found ->
	    
	  fail 
      
let () = CCore.register UrlLogin.facebook begin fun i18n request response ->
  
  let success user = 

    let url = 
      match CPreserve.read_preserve_cookie request with
	| None -> 
	  let (++) = Box.Seg.(++) in 
	  UrlMe.build (Box.Seg.root ++ CSegs.me_pages) ( (), `News )
	| Some url -> url
    in 
    
    return (
      response
      |> CSession.with_login_cookie user false 
      |> Action.javascript (Js.redirect url)
      |> CPreserve.without_preserve_cookie
    )
  in

  confirm success i18n request response

end

