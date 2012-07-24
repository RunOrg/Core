(* © 2012 MRunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

let other_send_to_self uid (build : [`IsSelf] IUser.id -> MUser.t -> 
			    (from:string option -> 
			     subject:string O.run ->
			     html:Html.writer O.run -> unit O.run) -> unit O.run) = 
 
  (* Sending e-mail to self. *)
  let uid   = IUser.Assert.is_self uid in 
  let vuid  = IUser.Deduce.view uid in 
  
  let! user = ohm_req_or (return false) $ MUser.get vuid in

  (* Never send anything to destroyed users *)
  let! () = true_or (return false) (user # destroyed = None) in 

  let! () = ohm $ build uid user begin fun ~from ~subject ~html ->

    let! () = ohm $ MAdminLog.log ~uid:(IUser.decay uid) MAdminLog.Payload.SendMail in 
    
    let! subject = ohm subject in
    let! html    = ohm html in
    let  html    = Html.to_html_string html in
    
    let to_email   = user # email in 
    let to_name    = user # fullname in
    let from_email = "no-reply@runorg.com" in
    let from_name  = match from with 
      | None      -> "RunOrg" 
      | Some name -> name ^ " (RunOrg)"
    in
    
    let () = 

      (*
      Netsendmail.compose 
	~in_charset:`Enc_utf8
	~out_charset:`Enc_utf8
	~from_addr:(from_name, from_email)
	~to_addrs:[to_name, to_email]
	~subject:subject
	~content_type:("text/html", ["charset", Mimestring.mk_param "UTF-8"])
	~container_type:("multipart/alternative",[])
	html
      |> Netsendmail.sendmail ;
      *)

      Util.log "Sent to: %s <%s>" to_name to_email 
    in
    
    return ()
      
  end in
  
  return true

let send_to_self uid build =
  other_send_to_self uid (fun uid user send -> build uid user (send ~from:None))
