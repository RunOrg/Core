(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal
open O

let parse_funnel_id = function 
  | None -> IFunnel.gen () 
  | Some string ->
    if String.length string = 11 then IFunnel.of_string string
    else IFunnel.gen () 

let grab_funnel arg = 
  let id = parse_funnel_id arg in
  let! funnel = ohm (MFunnel.get id) in
  let funnel = BatOption.default MFunnel.default funnel in 
  return (id, funnel)

let parse_vertical_id = function
  | None        -> return None
  | Some string -> let vid = IVertical.of_string string in 
		   let! _ = ohm_req_or (return None) (MVertical.get vid) in
		   return (Some vid)

let user_id req = 
  req # cookie CSession.name
  |> BatOption.bind CSession.get_login_cookie
  |> BatOption.map IUser.Deduce.unsafe_is_anyone 

(* CConfirm e-mail -------------------------------------------------------------------------- *)

let mail_i18n = CLogin_common.mail_i18n

module CConfirm = Fmt.Make(struct
  module IUser   = IUser
  module IFunnel = IFunnel
  type json t = IUser.t * IFunnel.t
end)

let send_confirm_mail_task =
  Task.register "login.funnel.signup" CConfirm.fmt begin fun (uid,fid) _ ->
    let! success = ohm $ MMail.send_to_self uid
      begin fun uid user send ->
	let uid  = IUser.Deduce.self_can_login uid in 
	VMail.SignupConfirm.send send mail_i18n
	  (object 
	    method fullname = user # fullname
	    method email    = user # email
	    method url      = UrlFunnel.create # confirm fid uid
	   end)
      end in
    return (if success then Task.Finished (uid,fid) else Task.Failed)
  end  

let send_confirm_mail fid uid = 
  MModel.Task.call send_confirm_mail_task (IUser.decay uid,fid) |> Run.map ignore

(* Asso form ------------------------------------------------------------------------------- *)

let asso_form ~authenticated = 
  Joy.begin_object (fun ~name ~desc ~key -> 
    (object
      method name = name
      method desc = desc
      method key  = key
     end))

  |> Joy.append (fun f name -> f ~name) 
      (Joy.string
	 ~field:".-asso-name input"
	 ~label:(".-asso-name .-label label",`label "instance.field.name") 
	 ~error:".-asso-name .-error label"
	 (fun _ seed -> seed # name)
	 (fun _ field string -> 
	   if string = "" then 
	     Bad (field, `label "field.required")
	   else
	     Ok string)) 

  |> Joy.append (fun f desc -> f ~desc) 
      (Joy.string
	 ~field:".-asso-desc textarea"
	 ~label:(".-asso-desc .-label label",`label "instance.field.desc") 
	 ~error:".-asso-desc .-error label"
	 (fun _ seed -> seed # desc)
	 (fun _ field string -> Ok string)) 
      
  |> Joy.append (fun f key -> f ~key) 
      (Joy.string
	 ~field:".-asso-key input"
	 ~label:(".-asso-key .-label label",`label "instance.field.key") 
	 ~error:".-asso-key .-error label"
	 (fun _ seed -> seed # key)
	 (fun _ field string -> 
	   if string = "" then 
	     Bad (field, `label "field.required")
	   else
	     Ok string)) 

  |> Joy.end_object
      ~html:("",VFunnel.Form.render authenticated)

(* CLogin form ------------------------------------------------------------------------------ *)

let login_form = 
  Joy.begin_object (fun ~login ~password -> 
    (object
      method login    = snd login
      method password = password
     end),
    (object
      method login = fst login
     end)
  )

  |> Joy.append (fun f login -> f ~login) 
      (Joy.string
	 ~field:".-login input"
	 ~label:(".-login .-label label",`label "login.login-form.login") 
	 ~error:".-login .-error label"
	 (fun _ () -> "")
	 (fun _ field string -> 
	   if string = "" then 
	     Bad (field, `label "field.required")
	   else
	     Ok (field,string))) 

  |> Joy.append (fun f password -> f ~password) 
      (Joy.string
	 ~field:".-password input"
	 ~label:(".-password .-label label",`label "login.login-form.pass") 
	 ~error:".-password .-error label"
	 (fun _ () -> "")
	 (fun _ field string -> 
	   if string = "" then 
	     Bad (field, `label "field.required")
	   else
	     Ok string)) 

  |> Joy.end_object
      ~html:("",VFunnel.LoginForm.render ())

(* CLogin form ------------------------------------------------------------------------------ *)

let signup_form = 
  Joy.begin_object (fun ~firstname ~lastname ~login ~password ~password2 -> 
    (object
      method firstname = firstname
      method lastname  = lastname
      method login     = snd login
      method password  = password
      method password2 = snd password2
     end), 
    (object
      method password2 = fst password2
      method login     = fst login
     end)
  )

  |> Joy.append (fun f firstname -> f ~firstname) 
      (Joy.string
	 ~field:".-firstname input"
	 ~label:(".-firstname .-label label",`label "login.signup-form.firstname") 
	 ~error:".-firstname .-error label"
	 (fun _ () -> "")
	 (fun _ field string -> 
	   if string = "" then 
	     Bad (field, `label "field.required")
	   else
	     Ok string)) 

  |> Joy.append (fun f lastname -> f ~lastname) 
      (Joy.string
	 ~field:".-lastname input"
	 ~label:(".-lastname .-label label",`label "login.signup-form.lastname") 
	 ~error:".-lastname .-error label"
	 (fun _ () -> "")
	 (fun _ field string -> 
	   if string = "" then 
	     Bad (field, `label "field.required")
	   else
	     Ok string)) 

  |> Joy.append (fun f login -> f ~login) 
      (Joy.string
	 ~field:".-login input"
	 ~label:(".-login .-label label",`label "login.signup-form.login") 
	 ~error:".-login .-error label"
	 (fun _ () -> "")
	 (fun _ field string -> 
	   if string = "" then 
	     Bad (field, `label "field.required")
	   else
	     Ok (field, string))) 

  |> Joy.append (fun f password -> f ~password) 
      (Joy.string
	 ~field:".-password input"
	 ~label:(".-password .-label label",`label "login.signup-form.pass") 
	 ~error:".-password .-error label"
	 (fun _ () -> "")
	 (fun _ field string -> 
	   if string = "" then 
	     Bad (field, `label "field.required")
	   else
	     Ok string)) 

  |> Joy.append (fun f password2 -> f ~password2) 
      (Joy.string
	 ~field:".-password2 input"
	 ~label:(".-password2 .-label label",`label "login.signup-form.pass2") 
	 ~error:".-password2 .-error label"
	 (fun _ () -> "")
	 (fun _ field string -> 
	   if string = "" then 
	     Bad (field, `label "field.required")
	   else
	     Ok (field,string))) 

  |> Joy.end_object
      ~html:("",VFunnel.SignupForm.render ())

(* Controller actions ---------------------------------------------------------------------- *)

let start i18n req res = 
  return $ O.Action.redirect (UrlCatalog.index # build) res

let () = CCore.register UrlFunnel.start   start 
let () = CCore.register UrlFunnel.restart start
let () = CCore.register UrlSplash.product start 

let () = CCore.register UrlFunnel.pick begin fun i18n req res ->

  let fid = parse_funnel_id (req # args 1) in

  let restart = return (Action.redirect (UrlFunnel.restart # build fid) res) in

  let! vid = ohm_req_or restart (parse_vertical_id (req # args 0)) in
  let! ()  = ohm (MFunnel.set_vertical fid vid) in

  return (Action.redirect (UrlFunnel.edit # build fid) res)

end

let () = CCore.register UrlFunnel.edit begin fun i18n req res ->

  let! (fid,funnel) = ohm (grab_funnel (req # args 0)) in
  let uidopt = user_id req in
  let restart = return (Action.redirect (UrlFunnel.restart # build fid) res) in
  let! vertical = ohm_req_or restart (MVertical.get (funnel.MFunnel.Data.vertical)) in
  let picked_vertical = object
    method title   = `label (vertical # name)
    method summary = vertical # summary 
    method catalog = UrlCatalog.index # build
  end in

  let render_form = 

    let form = 
      Joy.create 
	~template:(asso_form ~authenticated:(uidopt <> None))
	~i18n
	~source:(Joy.from_seed MFunnel.Data.(object
	  method name = funnel.name
	  method desc = funnel.desc
	  method key  = funnel.key
	end))
    in

    let keyurl = UrlFunnel.free_name # build in
    
    fun vctx -> 
      Joy.render form (UrlFunnel.post # build fid) vctx
      |> View.Context.add_js_code (Js.assoKey keyurl)
  in
  
  let data = object
    method pickVertical = None
    method vertical = Some picked_vertical
    method form = Some render_form
    method asso = None
    method account = None
  end in 

  let title = `label "start.2.title" in

  CCore.render
    ~theme:("splash",`RunOrg)
    ~title:(return (I18n.get i18n title))
    ~body:(return (VFunnel.Page.render data i18n))
    res

end

let () = CCore.register UrlFunnel.post begin fun i18n req res ->

  let uidopt = user_id req in

  let form = 
    Joy.create
      ~template:(asso_form ~authenticated:(uidopt <> None))
      ~i18n
      ~source:(Joy.from_post_json (req # json))
  in

  match Joy.result form with
    | Bad errors ->
      
      let json = Joy.response (Joy.set_errors errors form) in
      return (Action.json json res)
	
    | Ok result ->

      let! (fid,funnel) = ohm (grab_funnel (req # args 0)) in
      let! key = ohm (MInstance.free_name (result # key)) in
      let name = result # name and desc = result # desc in 

      let! () = ohm (MFunnel.set_info fid name desc key) in
	
      let url = UrlFunnel.account # build fid in
	
      return (Action.javascript (Js.redirect url) res)

end

let () = CCore.register UrlFunnel.account begin fun i18n req res ->

  let! (fid,funnel) = ohm (grab_funnel (req # args 0)) in

  let show_page = 

    let restart = return (Action.redirect (UrlFunnel.restart # build fid) res) in
    let! vertical = ohm_req_or restart 
      (MVertical.get (funnel.MFunnel.Data.vertical)) 
    in
    let picked_vertical = object
      method title   = `label (vertical # name)
      method summary = vertical # summary 
      method catalog = UrlCatalog.index # build
    end in
    
    let edit = return (Action.redirect (UrlFunnel.edit # build fid) res) in
    let! key = ohm (MInstance.free_name funnel.MFunnel.Data.key) in
    let! () = true_or edit MFunnel.Data.(funnel.name <> "" && funnel.key = key) in
    let asso = MFunnel.Data.(object
      method name = funnel.name
      method key  = funnel.key
      method desc = funnel.desc
    end) in
    
    let login_form = 
      Joy.create 
	~template:login_form 
	~i18n
	~source:Joy.empty
    in
    
    let signup_form = 
      Joy.create 
	~template:signup_form 
	~i18n
	~source:Joy.empty
    in
    
    let account = object
      method fb_url     = UrlFunnel.facebook # build fid
      method fb_channel = UrlLogin.fb_channel # build
      method fb_app_id  = MModel.Facebook.config # app_id
      method login      = Joy.render login_form  (UrlFunnel.do_login # build fid)
      method signup     = Joy.render signup_form (UrlFunnel.signup # build fid)
    end in
    
    let data = object
      method pickVertical = None
      method vertical = Some picked_vertical
      method form = None
      method asso = Some asso
      method account = Some account
    end in 
    
    let title = `label "start.3.title" in
    
    CCore.render
      ~theme:("splash",`RunOrg)
      ~title:(return (I18n.get i18n title))
      ~body:(return (VFunnel.Page.render data i18n))
      res
  in
  
  match user_id req with 
    | None -> show_page 
    | Some _ -> let url = UrlFunnel.create # build fid in 
		return (Action.redirect url res)

end

let () = CCore.register UrlFunnel.do_login begin fun i18n req res ->

  let form = 
    Joy.create
      ~template:login_form
      ~i18n
      ~source:(Joy.from_post_json (req # json))
  in

  let with_errors errors = 
    let json = Joy.response (Joy.set_errors errors form) in
    return (Action.json json res)
  in

  match Joy.result form with
    | Bad errors -> with_errors errors     
    | Ok (result,fields) ->
      
      let fail = with_errors [
	fields # login, `label "login.login-form.login.invalid"
      ] in 

      let! user = ohm_req_or fail (MUser.by_email (result # login)) in
      let! ok   = ohm_req_or fail (MUser.knows_password (result # password) user) in
      
      let user = IUser.Deduce.self_can_login ok in

      let fid = parse_funnel_id (req # args 0) in
      let url = UrlFunnel.create # build fid in

      return (
	res
        |> CSession.with_login_cookie user false
	|> Action.javascript (Js.redirect url)
      )   
end

let () = CCore.register UrlFunnel.signup begin fun i18n req res ->

  let fid = parse_funnel_id (req # args 0) in

  let form = 
    Joy.create
      ~template:signup_form
      ~i18n
      ~source:(Joy.from_post_json (req # json))
  in

  let with_errors errors = 
    let json = Joy.response (Joy.set_errors errors form) in
    return (Action.json json res)
  in

  match Joy.result form with
    | Bad errors -> with_errors errors     
    | Ok (result,fields) ->

      if result # password <> result # password2 then
	with_errors [ 
	  fields # password2, `label "login.signup-form.pass2.invalid"
	]
      else 

	let details = object
	  method firstname = result # firstname
	  method lastname  = result # lastname
	  method email     = result # login
	  method password  = result # password
	end in

	let! create = ohm (MUser.quick_create details) in

	match create with 
	  | `created id -> 
	    
	    let! () = ohm (send_confirm_mail fid id) in
	    
	    let html = VLogin.Signup.success ~email:(details # email) ~i18n in
	    let title = I18n.translate i18n (`label "login.signup-form.success.title") in
	    
	    return 
	      (Action.javascript (Js.Dialog.create html title) res)
	      
	  | `duplicate id -> 
	    
            (* Creation failed because a confirmed user already exists with this email *)
	    
	    let! () = ohm (CLogin.Lost.send_reset_mail id) in
	    
	    let html = VLogin.Signup.taken ~email:(details # email) ~i18n in
	    let title = I18n.translate i18n (`label "login.signup-form.taken.title") in
	    
	    return 
	      (Action.javascript (Js.Dialog.create html title) res)
	      
	  | `error -> 
	    
	    return 
	      (Action.javascript (Js.message (I18n.get i18n (`label "view.error"))) res)

end

let () = CCore.register UrlFunnel.facebook begin fun i18n req res ->

  let success user = 
    let fid = parse_funnel_id (req # args 0) in
    let url = UrlFunnel.create # build fid in 

    return (
      res
      |> CSession.with_login_cookie user false
      |> Action.javascript (Js.redirect url)
    )
  in

  CLogin.Facebook.confirm success i18n req res

end

let () = CCore.register UrlFunnel.free_name begin fun i18n req res ->
  let name = req # post "value" |> BatOption.default "" in    
  let! free = ohm (MInstance.free_name name) in
  return (Action.json [ "value" , Json_type.Build.string free ] res)
end

let () = CCore.register UrlFunnel.create begin fun i18n req res ->

  let! (fid,funnel) = ohm (grab_funnel (req # args 0)) in
  
  (* Check vertical *)
  let restart = return (Action.redirect (UrlFunnel.restart # build fid) res) in
  let! vertical = ohm_req_or restart 
    (MVertical.get (funnel.MFunnel.Data.vertical)) 
  in
    
  (* Check asso information *)
  let edit = return (Action.redirect (UrlFunnel.edit # build fid) res) in
  let! key = ohm (MInstance.free_name funnel.MFunnel.Data.key) in
  let! () = true_or edit MFunnel.Data.(funnel.name <> "" && funnel.key = key) in
  
  (* Extract the user and the cookie-setting function *)
  let! (uidopt, cookieset) = ohm begin

    let from_session = 
      req # cookie CSession.name
      |> BatOption.bind CSession.get_login_cookie
    in

    let! uid   = req_or (return (from_session, identity)) (req # args 1) in
    let! proof = req_or (return (None, identity)) (req # args 2) in
    
    let uidopt = IUser.Deduce.from_login_token proof (IUser.of_string uid) in
    
    let! uid   = req_or (return (None, identity)) uidopt in

    let self = 
      (IUser.Deduce.is_self
	 (* This is a core action *)
	 (ICurrentUser.Assert.is_safe uid))
    in

    let confirmable = 
      IUser.Deduce.self_can_confirm self
    in

    let login = 
      IUser.Deduce.self_can_login self
    in

    let! exists = ohm (MUser.confirm confirmable) in

    if exists then return (Some uid, CSession.with_login_cookie login false)
    else return (None, identity)

  end in

  (* Check user *)
  let account = return (Action.redirect (UrlFunnel.account # build fid) res) in
  let! uid = req_or account uidopt in

  (* Start the instance creation *)
  let usr = 
    (IUser.Deduce.is_self
       (* This is a core action *)
       (ICurrentUser.Assert.is_safe uid))
  in

  let! iid = ohm MFunnel.Data.(begin
    MInstance.create
      ~pic:None
      ~desc:(Some funnel.desc)
      ~site:None
      ~who:usr
      ~name:funnel.name
      ~key:funnel.key
      ~address:None
      ~contact:None
      ~vertical:funnel.vertical
  end) in

  (* Redirect to the instance *)

  let! instance = ohm (MInstance.get iid) in

  let url =
    match instance with 
      | Some inst -> UrlR.start # build inst 
      | None      -> UrlMe.build Box.Seg.(root ++ CSegs.me_pages) ((),`Network)      
  in
  
  return (Action.redirect url (cookieset res))

end

