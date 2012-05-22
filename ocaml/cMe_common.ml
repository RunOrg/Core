(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let notfound req res = 
  let body = O.Box.fill (Asset_Me_PageNotFound.render ()) in
  O.Box.response ~prefix:"/404" ~parents:[] "" O.BoxCtx.make body req res 

let action f req res = 

  (* Drop "me/ajax" from the path. *)
  let path = BatList.drop 2 (BatString.nsplit (req # path) "/") in

  (* Extract user from cookie *)
  let user = CSession.check req in 
  let user = match user with 
    | `None     -> None
    | `Old cuid -> Some (ICurrentUser.decay cuid)
    | `New cuid -> Some (ICurrentUser.decay cuid)
  in

  (* Redirect or run action *)
  match user with 
    | None -> let url = UrlLogin.save_url path in
	      let js  = Js.redirect (Action.url UrlLogin.login () url) () in
	      return $ Action.javascript js res
    | Some cuid -> f cuid req res

let define (base,prefix,parents,define) body =
  define (action (fun cuid req res -> 
    O.Box.response ~prefix ~parents base O.BoxCtx.make (body cuid) req res
  ))

