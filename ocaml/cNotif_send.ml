(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let delay = 10.0 (* seconds *)

let () = O.async # periodic 1 begin 
  let! result = ohm $ MNotif.send begin fun full -> 
    let! _ = ohm $ MMail.other_send_to_self (full # uid) begin fun self user send ->
      let! subject, text, html = ohm (full # mail self user) in
      let  owid = user # white in
      let! from = ohm (match full # from with None -> return None | Some aid ->
	let! details = ohm (MAvatar.details aid) in
	return (details # name)) in
      send ~owid ~from ~subject:(return subject) ~html:(return html) 
    end in 
    return () 
  end in
  return (if result then None else Some delay)
end 
