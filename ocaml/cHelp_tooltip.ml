(* © 2012 RunOrg *) 

open Ohm 
open Ohm.Universal
open BatPervasives

let newhere_tooltip_closed = MUser.Registry.property Fmt.Bool.fmt "newhere_tooltip_closed"

let () = UrlClient.def_newhere $ CClient.action begin fun access req res ->

  let uid = IUser.Deduce.is_anyone (MActor.user (access # actor)) in

  if req # get "mode" = Some "check" then
  
    let! closed = ohm $ MUser.Registry.get uid newhere_tooltip_closed in 
    let  closed = closed = Some true in 
    let  show   = not closed && CAccess.admin access <> None in

    return (Action.json [ "ok", Json.Bool show ] res)

  else if req # post <> None then

    let! () = ohm $ MUser.Registry.set uid newhere_tooltip_closed true in

    return res

  else

    return res

end
