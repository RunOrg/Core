(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

let () = UrlNetwork.def_unbound begin fun req res ->

  let uid = CSession.get req in
  let iid = req # args in 

  let not_found = C404.render (req # server) uid res in

  let! profile = ohm_req_or not_found (MInstance.Profile.get iid) in

  if snd (profile # key) <> req # server then 

    (* Wrong domain name : redirect *)
    let url = Action.url (req # self) (snd (profile # key)) iid in
    return (Action.redirect url res)

  else if profile # unbound = None then
    
    (* Profile is bound : redirect *)
    let url = Action.url UrlClient.website (profile # key) () in
    return (Action.redirect url res)

  else

    (* Profile is unbound : render wait page *)
    let html = Asset_Network_Unbound.render (object
      method navbar = (req # server,uid,None)
      method name   = profile # name
      method url    = Action.url UrlNetwork.install (req # server) (req # args) 
    end) in
    
    CPageLayout.core (req # server) `Network_Unbound html res

end

let () = UrlNetwork.def_install begin fun req res ->

  let uid = CSession.get req in
  let iid = req # args in 

  let! profile_opt = ohm $ MInstance.Profile.get iid in
  let  owners_opt  = BatOption.bind (#unbound) profile_opt in 
  
  let status = 
    match owners_opt with None -> `Missing | Some owners ->
      match CSession.check req with 
	| `New cuid when List.mem (IUser.Deduce.is_anyone cuid) owners ->
	  `UnconfirmedOwner (IUser.Deduce.is_anyone cuid) 
	| `Old cuid when List.mem (IUser.Deduce.is_anyone cuid) owners ->
	  `ConfirmedOwner cuid
	| _ -> `NotOwner owners
  in


  if req # post <> None then

    (* This is a POST : trigger the notifications *)
    
    let  payload = `CanInstall iid in 

    let! () = ohm begin 
      match status with 
	| `UnconfirmedOwner uid -> MNotify.Store.create payload uid
	| `NotOwner owners -> Run.list_iter (MNotify.Store.create payload) owners
	| `ConfirmedOwner _
	| `Missing -> return () 
    end in

    let redirect = 
      let url = Action.url (req # self) (req # server) (req # args) in
      return (Action.redirect url res) 
    in

    redirect

  else

    (* This is a GET (which happened, probably, after a POST) *)

    let not_found = C404.render (req # server) uid res in

    let! profile = req_or not_found profile_opt in
    let! owners  = req_or not_found owners_opt in 

    let html = Asset_Network_Install.render (object
      method navbar = (req # server,uid,None)
      method name   = profile # name
      method owid   = snd (profile # key) 
      method email  = ConfigWhite.email (snd (profile # key))
    end) in
    
    CPageLayout.core (req # server) `Network_Unbound html res

end
