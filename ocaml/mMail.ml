(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

let ping = 
  ConfigPacemkr.every 60. begin fun email freq -> 
    ConfigPacemkr.send ~nature:"E-mail Sender" "#$pid"
      "%s (%.2f / minute)" email freq
  end 

let send uid (build : [`IsSelf] IUser.id -> MUser.t ->
	      (owid:IWhite.t option ->
	       from:string option -> 
	       subject:string ->
	       text:string ->
	       html:Html.writer -> unit O.run) -> unit O.run) =

  (* Sending e-mail to self. *)
  let uid   = IUser.Assert.is_self uid in 
  let vuid  = IUser.Deduce.view uid in 
  
  let! user = ohm_req_or (return ()) $ MUser.get vuid in

  (* Never send anything to destroyed users *)
  let! () = true_or (return ()) (user # destroyed = None) in 

  build uid user begin fun ~owid ~from ~subject ~text ~html ->

    let! () = ohm $ MAdminLog.log ~uid:(IUser.decay uid) MAdminLog.Payload.SendMail in 
    
    let html       = Html.to_html_string html in
    
    let to_email   = user # email in 
    let to_name    = user # fullname in
    let from_email = ConfigWhite.no_reply owid in
    let from_name  = match from with 
      | None      -> ConfigWhite.name owid 
      | Some name -> name ^ " (" ^ ConfigWhite.short owid ^ ")"
    in
    
    return begin 
      try 
	
	Netsendmail.compose 
	  ~in_charset:`Enc_utf8
	  ~out_charset:`Enc_utf8
	  ~from_addr:(from_name, from_email)
	  ~to_addrs:[to_name, to_email]
	  ~subject:subject
	  ~content_type:("text/plain", ["charset", Mimestring.mk_param "UTF-8"])
	  ~container_type:("multipart/alternative",[])
	  ~attachments:[
	    let header = new Netmime.basic_mime_header [ "Content-type", "text/html;charset=UTF-8" ] in
	    let body   = new Netmime.memory_mime_body html in
	    header, `Body body 
	  ]
	  text
	|> Netsendmail.sendmail ;
	
	Util.log "Sent to: %s <%s> From: %s" to_name to_email from_name ;
	
	ping to_email   

      with exn -> 

	Util.log "Error sending to: %s <%s> : %s" to_name to_email
	  (Printexc.to_string exn) 

    end

  end 

(* Below : obsolete, delete soon. *)
  
let other_send_to_self uid (build : [`IsSelf] IUser.id -> MUser.t -> 
			    (owid:IWhite.t option ->
			     from:string option -> 
			     subject:string O.run ->
			     html:Html.writer O.run -> unit O.run) -> unit O.run) = 
 
  (* Sending e-mail to self. *)
  let uid   = IUser.Assert.is_self uid in 
  let vuid  = IUser.Deduce.view uid in 
  
  let! user = ohm_req_or (return false) $ MUser.get vuid in

  (* Never send anything to destroyed users *)
  let! () = true_or (return false) (user # destroyed = None) in 

  let! () = ohm $ build uid user begin fun ~owid ~from ~subject ~html ->

    let! () = ohm $ MAdminLog.log ~uid:(IUser.decay uid) MAdminLog.Payload.SendMail in 
    
    let! subject = ohm subject in
    let! html    = ohm html in
    let  html    = Html.to_html_string html in
    
    let to_email   = user # email in 
    let to_name    = user # fullname in
    let from_email = ConfigWhite.no_reply owid in
    let from_name  = match from with 
      | None      -> ConfigWhite.name owid 
      | Some name -> name ^ " (" ^ ConfigWhite.short owid ^ ")"
    in
    
    let () = 
      try 
	
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
	
	Util.log "Sent to: %s <%s> From: %s" to_name to_email from_name ;
	
	ping to_email   

      with exn -> 

	Util.log "Error sending to: %s <%s> : %s" to_name to_email
	  (Printexc.to_string exn) 

    in
    
    return ()
      
  end in
  
  return true

let send_to_self uid build =
  other_send_to_self uid (fun uid user send -> build uid user (send ~from:None))
