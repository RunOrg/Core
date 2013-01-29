(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let do_extract fail req res = 
  
  let  cuid = CSession.get req in
  let  p404 = return $ Bad (fail cuid res) in

  let  key      = req # server in
  let! iid      = ohm_req_or p404 $ MInstance.by_key key in
  let! instance = ohm_req_or p404 $ MInstance.get iid in

  return $ Ok (cuid, key, iid, instance) 

let extract req res = ohm_ok_or identity (do_extract (C404.render (snd (req # server))) req res)

let extract_ajax req res = 
  let redirect _ res = 
    return $ Action.javascript 
      (Js.redirect (Action.url UrlClient.website (req # server) ()) ()) res
  in
  ohm_ok_or identity (do_extract redirect req res) 

let () = UrlClient.def_root begin fun req res -> 

  let! cuid, key, iid, instance = extract req res in

  let if_new () = 
    let html = Asset_Client_ConfirmFirst.render (object
      method navbar = (snd key, cuid, Some iid)
    end) in 
    CPageLayout.core (snd key) (`Client_Title (instance # name)) html res
  in

  let if_old () =

    let url = Action.url UrlClient.ajax key [] in
    let default = "/inbox" in
    
    let html = Asset_Client_Page.render (object
      method navbar = (snd key,cuid,Some iid)
      method box    = OhmBox.render ~url ~default
    end) in
    
    CPageLayout.core ~deeplink:true (snd key) (`Client_Title (instance # name)) html res
  in

  let if_no_token () =
    return $ Action.redirect (Action.url UrlClient.join (instance # key) None) res
  in

  match CSession.check req with 
    | `Old cuid -> begin 
      let! access_opt = ohm $ CAccess.make cuid iid instance in
      match access_opt with 
	| Some _ -> let! () = ohm $ MInstance.visit cuid iid in 
		    if_old ()
	| None   -> if_no_token ()
    end
    | `New cuid -> let! status = ohm $ MAvatar.status iid cuid in 
		   if status = `Contact then if_no_token () else if_new ()
    | `None     -> if_old () (* The JS will redirect to the login page *)
  
end

let () = UrlClient.def_notfound begin fun req res -> 

  let! cuid, key, iid, instance = extract req res in
  C404.render ~iid (snd key) cuid res

end 
    
let () = UrlClient.def_ajax begin fun req res -> 

  let body = O.Box.fill (Asset_Client_PageNotFound.render ()) in
  O.Box.response ~prefix:"/404" ~parents:[] "" O.BoxCtx.make body req res 

end

let action f req res = 

  (* Find current location *)
  let! _, key, iid, instance = extract_ajax req res in  

  let if_no_login () = 
    
    (* Drop "intranet/ajax" from the path. *)
    let path = BatList.drop 2 (BatString.nsplit (req # path) "/") in

    (* Redirect or run action *)
    let url = UrlLogin.save_url ~iid path in
    let js  = Js.redirect (Action.url UrlLogin.login (snd key) url) () in
    return $ Action.javascript js res

  in

  let panic () = 
    (* Reload, so the main page may deal with it. *)
    return $ Action.javascript (Js.reload ()) res
  in
  
  match CSession.check req with 
    | `Old cuid -> begin 
      let! access_opt = ohm $ CAccess.make cuid iid instance in
      match access_opt with 
	| Some access -> f access req res
	| None        -> panic ()
    end
    | `New cuid -> panic ()
    | `None     -> if_no_login ()

let define ?back (base,prefix,parents,define) body =
  define (action (fun access req res -> 
    let base = base (req # server) in
    let! res = ohm $ O.Box.response ~prefix ~parents base O.BoxCtx.make (body access) req res in
    let back = BatOption.map (fun url -> url (access # instance # key) []) back in	 
    return $ Action.javascript (Js.clientBack back ()) res 
  ))

let define_admin ?back def body = 
  define ?back def begin fun access -> 
    match CAccess.admin access with 
      | None -> O.Box.fill (Asset_Client_PageForbidden.render ()) 
      | Some access -> body access
  end
