(* © 2012 RunOrg *) 

open Ohm 
open Ohm.Universal
open BatPervasives

let () = UrlClient.def_newhere $ CClient.action begin fun access req res ->

  if req # get "mode" = Some "check" then
  
    let show = CAccess.admin access <> None in

    return (Action.json [ "ok", Json.Bool show ] res)

  else

    return res

end
