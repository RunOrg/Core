(* © 2012 MRunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

let other_send_to_self uid (build : [`IsSelf] IUser.id -> MUser.t -> 
			    (from:string option -> 
			     subject:Ohm.View.text -> 
			     text:Ohm.View.text ->
			     html:Ohm.View.text option -> unit O.run) -> unit O.run) = 
 
  (* Sending e-mail to self. *)
  let uid   = IUser.Assert.is_self uid in 
  let vuid  = IUser.Deduce.self_can_view uid in 
  
  let! user = ohm_req_or (return false) $ MUser.get vuid in

  (* Never send anything to destroyed users *)
  let! () = true_or (return false) (user # destroyed = None) in 

  let! () = ohm $ build uid user begin fun ~from ~subject ~text ~html ->
    
    let subject = View.write_to_string subject in
    let text    = View.write_to_string text    in
    let html    = BatOption.map View.write_to_string html    in
    
    let to_email   = user # email in 
    let to_name    = user # fullname in
    let from_email = "no-reply@runorg.com" in
    let from_name  = match from with 
      | None      -> "RunOrg" 
      | Some name -> name ^ " (RunOrg)"
    in
    
    let () = match html with 
      | Some html -> 
	
	Netsendmail.compose 
	  ~in_charset:`Enc_utf8
	  ~out_charset:`Enc_utf8
	  ~from_addr:(from_name, from_email)
	  ~to_addrs:[to_name, to_email]
	  ~subject:subject
	  ~content_type:("text/plain", ["charset", Mimestring.mk_param "UTF-8"])
	  ~container_type:("multipart/alternative",[])
	  ~attachments:[
	    Netsendmail.wrap_attachment 
	      ~content_type:("text/html", ["charset", Mimestring.mk_param "UTF-8"])
	      ~in_charset:`Enc_utf8
	      ~out_charset:`Enc_utf8
	      (new Netmime.memory_mime_body html)
	  ]
	  text
        |> Netsendmail.sendmail ;
	
	Util.log "Sent to: %s <%s>" to_name to_email 
	  
      | None ->
	
	Netsendmail.compose 
	  ~in_charset:`Enc_utf8
	  ~out_charset:`Enc_utf8
	  ~from_addr:(from_name, from_email)
	  ~to_addrs:[to_name, to_email]
	  ~subject:subject
	  text
        |> Netsendmail.sendmail ;
	
	Util.log "Sent to: %s <%s>" to_name to_email 
    in

    return ()

  end in
      
  return true

let send_to_self uid build =
  other_send_to_self uid (fun uid user send -> build uid user (send ~from:None))
