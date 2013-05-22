(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let mkurl = O.register O.core "ml" Action.Args.(r Id.arg) begin fun req res -> 
  
  let fail = return (Action.redirect "http://runorg.com/404" res) in

  let! url, mailing = ohm_req_or fail (MMailing.click (req # args)) in

  let url = url ^ "?" ^ mailing in
  
  return 
    (Action.with_cookie ~name:"mailing" ~value:mailing ~life:(3600 * 30)
       (Action.redirect url res))

end

let _ = O.register O.core "new-mail" Action.Args.none begin fun req res -> 
  
  let  fail = return res in 
  
  let! post = req_or fail (match req # post with 
    | Some (`POST post) -> Some post
    | _ -> None) in

  let! mailing, email, name, url = req_or fail (
    try let mailing = BatPMap.find "mailing" post in 
	let email   = BatPMap.find "email" post in 
	let name    = BatPMap.find "name" post in
	let url     = BatPMap.find "url" post in 
	Some (mailing, email, name, url)
    with _ -> None) in
  
  let! id = ohm (MMailing.create ~mailing ~email ~name ~url) in
  
  let  url = Action.url mkurl None id in 

  return (Action.raw ~mime:"text/plain" ~data:url res)

end
