(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

let action kind i18n request response = 
  
  let p404  = C404.render i18n response in

  let! self = CLogin_common.with_self 
    ~proof:(request # args 1) 
    ~uid:(request # args 0) 
    ~fail:p404 
  in

  let! exists = ohm (MUser.confirm (IUser.Deduce.self_can_confirm self)) in

  if not exists then p404 else 
	    
    let! _ = ohm $ MNews.FromLogin.create (`Login (IUser.decay self)) in

    let url = 
      let (++) = Box.Seg.(++) in 
      let build = UrlMe.build (Box.Seg.root ++ CSegs.me_pages ++ CSegs.me_account_tabs `View) in
      match kind with
	| `reset   -> build (((),`Account),`Password)
	| `confirm -> 
	  match CPreserve.read_preserve_cookie request with 
	    | Some url -> url
	    | None     -> build (((),`Account ),`View)      
    in      
	    
    return (
      response
      |> CSession.with_login_cookie (IUser.Deduce.self_can_login self) false 
      |> Action.redirect url
      |> CPreserve.without_preserve_cookie
    )
	  
let () = 
  CCore.register UrlLogin.reset (action `reset) ;
  CCore.register UrlLogin.confirm (action `confirm)


