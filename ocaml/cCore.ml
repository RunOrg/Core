(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

let maybe_admin request = 
  let cookie_opt = request # cookie CSession.name in 
  match cookie_opt with None -> false | Some cookie -> 
    let user_opt = CSession.unverified_user_id cookie in 
    match user_opt with None -> false | Some user -> MAdmin.user_may_be_admin user     

let js_fail code response = 
  return (Action.javascript code response)

let build_js_fail_message i18n msg response = 
  Action.javascript (Js.message (I18n.get i18n (`label msg))) response

let js_fail_message i18n msg response =
  return (build_js_fail_message i18n msg response)

let json_fail json response = 
  return (Action.json json response)

let redirect_fail url response =
  return (Action.redirect url response)

(* Header urls ---------------------------------------------------------------------- *)

let css_core   = ["/public/full.css"]

let css_splash = ["/public/full.css";
		  "/public/css/splash.css";
		  "/public/css/colorbox/colorbox.css"]

let css_client = ["/public/full.css";
		  "/public/css/carrelage.css"]
  
let js_splash  = ["/public/js/jquery.slider.js";
		  "/public/js/jquery.colorbox-min.js";
		  "/public/js/splash.js"]

let js_catalog = ["/public/js/jquery.cycle.lite.min.js";
		  "/public/js/jquery-address.min.js"]

(* Rendering ----------------------------------------------------------------------- *)

module Rendering = struct

  let head ctx =
    View.str 
      "<link rel=\"stylesheet\" href=\"/public/css/blueprint/screen.css\" type=\"text/css\" media=\"screen, projection\"> 
<link rel=\"stylesheet\" href=\"/public/css/blueprint/print.css\" type=\"text/css\" media=\"print\">
<!--[if lt IE 8]><link rel=\"stylesheet\" href=\"/public/css/blueprint/ie.css\" type=\"text/css\" media=\"screen, projection\">
<![endif]-->
<link rel=\"stylesheet\" href=\"/public/css/jqueryui-aristo/jquery-ui-1.8.4.custom.css\" type=\"text/css\" media=\"screen,projection\">
<link rel=\"shortcut icon\" href=\"/public/favicon.ico\"/>"
      ctx
          
  let render
      ?navbar
      ?start
      ?(js=JsBase.staticInit)
      ?(js_files=[])
      ?(css=css_core)
      ?theme
      ~title ~body res =

    let! start  = ohm $ BatOption.default (return identity) start  in
    let! navbar = ohm $ BatOption.default (return identity) navbar in
    let! body   = ohm $ body in
    let! title  = ohm $ title in 

    let body ctx = 
      ctx
      |> navbar
      |> View.str "<div id=start>"
      |> start 
      |> View.str "</div><div id=message><span></span></div>"
      |> body
    in
    
    let js_files = 
      "//runorg.com/public/js/jquery.min.js" 
      :: "//runorg.com/public/js/jquery-ui.min.js" 
      :: "//runorg.com/public/js/jquery.json-2.2.min.js" 
      :: "//runorg.com/public/js/jquery.tipsy.js"
      :: "/public/js/jog.js"
      :: "/public/js/runorg.js" 
      :: "/public/js/carrelage.js"
      :: "/public/js/joy.js"
      :: "/public/js/arr.js"
      :: "/public/full.js"
      :: js_files 
    in
    
    let body_classes = match theme with 
      | Some (t,`RunOrg) -> ["theme-" ^ t]
      | Some (t,`White)  -> ["theme-" ^ t ; "-white" ]
      | None -> [] 
    in

    return $ Layout.render
      ~js_files
      ~head  
      ~css_files:css
      ~title
      ~body
      ~body_classes
      ~js
      res

end

let render = Rendering.render      

let error500 i18n response = 
  Action.redirect "http://runorg.com/500.htm" response

let error500_js i18n response = 
  Action.javascript (Js.redirect "http://runorg.com/500.htm") response

(* Register a core action ------------------------------------------------------------------ *)

let _i18n = MModel.I18n.load (Id.of_string "i18n-common-fr") `Fr

let _ = Action.register UrlCore.retrack begin fun req res -> 

  let maybe_admin = maybe_admin req in 
  
  let  falsereq = object
    method cookie _ = None
  end in 

  let! session = CSession.with_tracking_cookie falsereq in 
  let  test = MSplash.test_of_session ~admin:maybe_admin session in
  
  Action.json ([ 
    "session", Json_type.String session ;
    "test",    Json_type.String test
  ]) res
    
end


let profileSessionRegister ctrl action = 

  Action.register ctrl begin fun req res -> 

    let maybe_admin = maybe_admin req in 

    let! session = CSession.with_tracking_cookie req in 
    let  test = MSplash.test_of_session ~admin:maybe_admin session in

    let response = action test req res in
    
    response

  end

let profileRegister ctrl action = 
  profileSessionRegister ctrl (fun _ -> action)
    
let register ?(fail=error500) ctrl action = 
  profileRegister ctrl begin fun req res ->
    let i18n = _i18n in 

    try action i18n req res |> Run.eval (new CouchDB.init_ctx) 
    with exn -> let _ = Run.eval (new CouchDB.init_ctx)
		  (MErrorAudit.on_frontend 
		     ~server:req # servername
		     ~url:req # path
		     ~user:(CSession.get_login_cookie CSession.name 
			       |> BatOption.map IUser.Deduce.unsafe_is_anyone)
		     ~exn)
		in
		fail i18n res
    		 
  end
    
module User = struct

  let register_ajax ctrl action = 
    let fail i18n response = build_js_fail_message i18n "view.error" response in 
    if ctrl # server <> `Core then 
      log "Core.User.register : %s : not a core path" (ctrl # path)
    else
      register ~fail ctrl begin fun i18n req response ->	
	let fail    response = 
	  Action.javascript (Js.redirect (UrlLogin.index # build)) response 
          |> return
	in
	let success user response = 
	  (* Nous sommes sur une action du CCore *)
	  action i18n (ICurrentUser.Assert.is_safe user) req response	    
	in
	match req # cookie CSession.name with 
	  | None        -> fail response
	  | Some cookie -> 
	    CSession.read_login_cookie cookie ~success ~fail response
      end

  let register ctrl action = 
    let fail = error500 in 
    if ctrl # server <> `Core then 
      log "Core.User.register : %s : not a core path" (ctrl # path)
    else
      register ~fail ctrl begin fun i18n req response ->	
	let fail    response = 
	  Action.redirect (UrlLogin.index # build) response 
	  |> CPreserve.with_preserve_cookie (UrlMe.me # build)
	  |> CSession.with_logout_cookie
	  |> return
	in
	let success user response = 
	  (* Nous sommes sur une action du CCore *)
	  action i18n (ICurrentUser.Assert.is_safe user) req response	    
	in
	match req # cookie CSession.name with 
	  | None        -> fail response
	  | Some cookie -> 
	    CSession.read_login_cookie cookie ~success ~fail response
      end

end

(* A few core actions ----------------------------------------------------------------------- *)

let () = register UrlCore.cancel begin fun i18n req res ->
  return (Action.html (fun c -> c) res)
end

(* Rendering the navbar --------------------------------------------------------------------- *)

let navbar name user user_name instance news_count message_count i18n = 

  let! instances = ohm $ MInstance.visit user instance in

  let extract_instance i = 
    
    let! pic_url_opt = ohm $ (match i # pic with 
      | None     -> return None
      | Some pic -> MFile.Url.get pic `Small
    ) in
    
    return (object
      method name     = i # name
      method url      = UrlR.home # build i 
      method messages = UrlR.build i O.Box.Seg.(root ++ CSegs.root_pages) ((),`Messages)
      method pic      = BatOption.default "" pic_url_opt	    
     end)
  in
  
  let! instances =  ohm $ Run.list_map extract_instance instances in
    
  let! instance_data_opt = ohm (match instance with 
    | None -> return None
    | Some iid -> MInstance.get iid 
  ) in

  let url_messages = match instance_data_opt with 
    | Some instance -> UrlR.build instance O.Box.Seg.(root ++ CSegs.root_pages) ((),`Messages)
    | None          -> match instances with 
	| []     -> UrlMe.build O.Box.Seg.(root ++ CSegs.me_pages) ((),`Messages)
	| i :: _ -> i # messages
  in
      
  return $ VCore.navbar
    ~url_home:    (UrlSplash.index # build)
    ~url_account: (UrlMe.build O.Box.Seg.(root ++ CSegs.me_pages) ((),`Account))
    ~url_news:    (UrlMe.build O.Box.Seg.(root ++ CSegs.me_pages) ((),`News))
    ~url_groups:  (UrlMe.build O.Box.Seg.(root ++ CSegs.me_pages) ((),`Network))
    ~url_create:  (UrlFunnel.start # build) 
    ~url_messages
    ~url_logout:  (UrlCore.logout # build)
    ~user_name
    ~instances:(instances :> VCore.assolink list)
    ~news_count 
    ~message_count
    ~name 
    ~i18n
    
  
  
