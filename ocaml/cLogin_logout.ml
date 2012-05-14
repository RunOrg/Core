(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

let () = CCore.register UrlCore.logout begin fun i18n request response ->
  Action.redirect (UrlLogin.index # build) response
  |> CSession.with_logout_cookie 
  |> return
end    
