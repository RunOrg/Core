(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let do_extract fail req res = 
  
  let  cuid = CSession.decay (CSession.check req) in
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
