(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O

let cookie = "RUNORG_SONDAGE"

let with_cookie (req:Action.request) res = 
    
  let thecookie = match req # cookie cookie with 
    | Some value -> value
    | None       -> 
      try  Run.eval (new CouchDB.init_ctx)
	(MSondage.start ~ip:(req # ip) ~query:(req # query)) 
      with _ -> ""     
  in
  
  Action.with_cookie ~name:cookie ~value:thecookie ~life:(3600*24*30) res
    
let _i18n = MModel.I18n.load (Id.of_string "i18n-splash-fr") `Fr
  
let register ctrl action = 
  Action.register ctrl begin fun req res ->
    with_cookie req (action _i18n req res)
  end 

(* ------------------------------------------------------------------------------------------ *)

let () = register UrlSplash.sondage begin fun i18n req ->
  Action.html begin fun js -> VSondage.render 
    ~ajax:(UrlSplash.sondage_a # build)
    ~final:(UrlSplash.sondage_p # build)
    ~i18n
  end 
end

(* ------------------------------------------------------------------------------------------ *)

let () = register UrlSplash.sondage_a begin fun i18n req res -> 
  begin match req # post "name", req # post "value", req # cookie cookie with
    | Some name, Some value, Some cookie ->
      let _ = Run.eval (new CouchDB.init_ctx)
	(MSondage.partial ~cookie ~name ~value ~ip:(req # ip)) in ()
    | _ -> ()
  end ;
  res
end

(* ------------------------------------------------------------------------------------------ *)

let () = register UrlSplash.sondage_p begin fun i18n req res ->
  begin match req # cookie cookie with 
    | Some cookie ->
      let _ = Run.eval (new CouchDB.init_ctx) 
	(MSondage.final ~cookie ~list:(req # postlist) ~ip:(req # ip)) in ()
    | _ -> ()
  end ;
  Action.redirect (UrlSplash.sondage_t # build) res
end

(* ------------------------------------------------------------------------------------------ *)

let () = register UrlSplash.sondage_t begin fun i18n req res ->
  Action.html (fun js -> VSondage.thanks ~i18n) res
end
