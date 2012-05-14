(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open O
open BatPervasives
open Ohm.Universal

let _i18n = MModel.I18n.load (Id.of_string "i18n-common-fr") `Fr

let register ?(fail=CCore.error500) ctrl action = 
  CCore.profileRegister ctrl begin fun request response ->    

    let i18n = _i18n in 

    let query = 
      let! instance_opt = ohm begin 
	let! iid_opt = ohm (MInstance.by_servername (request # servername)) in

	match iid_opt with      
	  | None -> return None
	  | Some iid -> 
	    
	    let! instance_opt = ohm (MInstance.get iid) in
	    
	    match instance_opt with 
	      | None -> return None 
	      | Some instance -> return (Some (iid, instance))
      end in

      match instance_opt with 
	| None                 -> return (Action.redirect (UrlSplash.index # build) response)
	| Some (iid, instance) -> action i18n (iid,instance) request response  
     
    in

    try Run.eval (new CouchDB.init_ctx) query with 
	exn -> let _ = Run.eval (new CouchDB.init_ctx)
		 (MErrorAudit.on_frontend 
		    ~server:request # servername
		    ~url:request # path
		    ~user:(CSession.get_login_cookie CSession.name
			      |> BatOption.map IUser.Deduce.unsafe_is_anyone)
		    ~exn)
	       in
	       fail i18n response

  end

module User = struct

  let register_ajax ?(fail=CCore.error500_js) extract ctrl action = 
    register ~fail ctrl begin fun i18n (iid,instance) request response ->
      let! vert  = ohm $ MVertical.get_cached (instance # ver) in
      let! white = ohm $ Run.opt_bind MWhite.get (instance # white) in
      let fail response = 
	Action.javascript (Js.redirect (UrlLogin.index # build)) response
	|> CPreserve.with_preserve_cookie (UrlR.r # build instance)
	|> CSession.with_logout_cookie
	|> return
      in
      let success user response =
	let! user_opt = ohm
	  (MAvatar.identify iid user |> Run.map extract) in
	match user_opt with 
	  | None      -> return (Action.redirect (UrlMe.me # build) response)
	  | Some isin -> let ctx = CContext.make_full isin instance vert white i18n in
			 action ctx request response	
      in
      match request # cookie CSession.name with 
	| None        -> fail response
	| Some cookie -> CSession.read_login_cookie cookie ~success ~fail response
    end      

  let register ?(fail=CCore.error500) extract ctrl action = 
    register ~fail ctrl begin fun i18n (iid,instance) request response ->
      let! vert  = ohm $ MVertical.get_cached (instance # ver) in
      let! white = ohm $ Run.opt_bind MWhite.get (instance # white) in
      let fail response = 
	Action.redirect (UrlLogin.index # build) response
	|> CPreserve.with_preserve_cookie (UrlR.r # build instance)
	|> CSession.with_logout_cookie
	|> return
      in
      let success user response =
	let! user_opt = ohm (MAvatar.identify iid user |> Run.map extract) in
	match user_opt with 
	  | None      -> return (Action.redirect (UrlMe.me # build) response)
	  | Some isin -> let ctx = CContext.make_full isin instance vert white i18n in
			 action ctx request response
      in
      match request # cookie CSession.name with 
	| None        -> fail response
	| Some cookie -> CSession.read_login_cookie cookie ~success ~fail response
    end      

end

(* Membership extractors ------------------------------------------------------------------ *)

let is_anyone  x = Some (IIsIn.Deduce.is_anyone x)
let is_contact x = IIsIn.Deduce.is_contact x
let is_token   x = IIsIn.Deduce.is_token x
let is_admin   x = IIsIn.Deduce.is_admin x
