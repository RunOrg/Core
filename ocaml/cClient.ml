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

let extract req res = ohm_ok_or identity (do_extract C404.render req res)

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
      method navbar = (cuid, Some iid)
    end) in 
    CPageLayout.core (`Client_Title (instance # name)) html res
  in

  let if_old () = 
    let url = Action.url UrlClient.ajax key [] in
    let default = "/home" in
    
    let html = Asset_Client_Page.render (object
      method navbar = (cuid,Some iid)
      method box    = OhmBox.render ~url ~default
    end) in
    
    CPageLayout.core ~deeplink:true (`Client_Title (instance # name)) html res
  in

  let if_no_token () =
    return res
  in

  match CSession.check req with 
    | `Old cuid -> begin 
      let! access_opt = ohm $ CAccess.make cuid iid instance in
      match access_opt with 
	| Some _ -> if_old ()
	| None   -> if_no_token ()
    end
    | `New cuid -> if_new ()
    | `None     -> if_old () (* The JS will redirect to the login page *)
  
end
    
let () = UrlClient.def_ajax begin fun req res -> 

  let body = O.Box.fill (Asset_Client_PageNotFound.render ()) in
  O.Box.response ~prefix:"/404" ~parents:[] "" O.BoxCtx.make body req res 

end
