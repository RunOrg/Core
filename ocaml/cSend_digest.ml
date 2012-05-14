(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

open CSend_common 

let _ =
 
  let! uid, summary = Sig.listen MDigest.Signals.on_send in 

  let render_next (bid,time,title) = object
    method url   = UrlBroadcast.link # build bid 
    method time  = time
    method title = title 
  end in
  
  let render_instance (iid,content) = 
    let! instance = ohm_req_or (return None) $ MInstance.get iid in 
    let! via      = ohm begin 
      match content # first # forward with None -> return None | Some fwd -> 
	let! instance = ohm_req_or (return None) $ MInstance.get (fwd # from) in 
	let  url      = UrlR.home # build instance in  
	return $ Some (url, instance # name)
    end in 
    
    let from_url = UrlR.home # build instance in 
    let title, html_body, text_body = match content # first # content with
      | `Post p -> let head = VText.head 500 (p # body) in
		   p # title, 
	           VText.format head,
	           VText.format_mail head
      | `RSS  r -> let short = OhmSanitizeHtml.cut ~max_lines:3 ~max_chars:500 (r # body) in
		   r # title, 
		   OhmSanitizeHtml.html short,
		   OhmSanitizeHtml.text short
    in 

    return $ Some (object
      method from      = instance # name
      method from_url  = from_url
      method via       = via 
      method url       = UrlBroadcast.link # build (content # first # id) 
      method time      = content # first # time
      method html_body = html_body
      method text_body = text_body
      method title     = title
      method next      = List.map render_next (content # next)
    end)
  in
  
  let! items = ohm $ Run.list_filter render_instance summary in 

  let () = Util.log "Prepared digest : size %d : user %s" 
    (List.length items) (IUser.to_string uid)
  in

  if items = [] then return () else 
  
    send_mail `digest uid 
      begin fun uid user send -> 
	let uid = IUser.Deduce.block uid in
	VMail.Digest.Mail.send send mail_i18n 
	  (object
	    method list     = items
	    method unsub    = UrlBroadcast.unsubscribe # build uid
	    method fullname = user # fullname
	   end) 
      end
