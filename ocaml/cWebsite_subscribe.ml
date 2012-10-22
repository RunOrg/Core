(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let template = 
  OhmForm.Skin.text 
    ~label:(AdLib.get `Website_Subscribe_Email) 
    (fun () -> return "") 
    (OhmForm.Convenience.email 
       ~required:(AdLib.get `Website_Subscribe_Required)
       (AdLib.get `Website_Subscribe_BadEmail))
    
  |> OhmForm.Skin.with_ok_button ~ok:(AdLib.get `Website_Subscribe_Button)

let render cuid key iid = 

  let! num_brc = ohm $ MBroadcast.count iid in 
  let! num_sbs = ohm $ MDigest.Subscription.count_followers iid in 
  
  let! follows = ohm begin match cuid with 
    | None      -> return false
    | Some cuid -> MDigest.Subscription.follows cuid iid 
  end in

  let  the_url = 
    let the_url = UrlClient.(if follows then unsubscribe else subscribe) in
    Action.url the_url key () 
  in

  let  form =
    if cuid <> None then None else 
      let form = OhmForm.create ~template ~source:OhmForm.empty in
      Some (Asset_Form_Small.render (OhmForm.Convenience.render form the_url))
  in

  Asset_Website_Subscribe.render (object
    method num_brc = num_brc
    method num_sbs = num_sbs
    method url     = the_url
    method follows = follows
    method form    = form 
  end) 

let respond cuid key iid res = 
  let! html = ohm $ render cuid key iid in
  return $ Action.json ["replace", Html.to_json html] res
   
let () = UrlClient.def_subscribe begin fun req res -> 

  if req # post = None then return res else 

    let! cuid, key, iid, _ = CClient.extract_ajax req res in
    
    match cuid with 
      | Some cuid -> 
	
	let! () = ohm $ MDigest.Subscription.subscribe cuid iid in    
	respond (Some cuid) key iid res

      | None -> 

	(* No current user : the form was sent, and we should have received
	   an e-mail. *)
	let! json = req_or (return res) (Action.Convenience.get_json req) in
	let form = OhmForm.create ~template ~source:(OhmForm.from_post_json json) in

	let fail errors =
	  let  form = OhmForm.set_errors errors form in
	  let! json = ohm $ OhmForm.response form in
	  return $ Action.json json res
	in
	
	let! email = ohm_ok_or fail $ OhmForm.result form in

	let! cuid = ohm $ MUser.listener_create email in
	
	match cuid with 

	  | None -> 
	    let url = Action.url UrlLogin.login (snd (req # server)) (UrlLogin.save_url ~iid []) in
	    return (Action.javascript (Js.redirect ~url ()) res)

	  | Some cuid -> 
	    let!  ()  = ohm $ MDigest.Subscription.subscribe cuid iid in
	    let! () = ohm $ MNews.Cache.prepare (IUser.Deduce.is_anyone cuid) in
	    return $ CSession.start (`New cuid) 
	      (Action.javascript (Js.reload ()) res)

end

let () = UrlClient.def_unsubscribe begin fun req res -> 

  if req # post = None then return res else 

    let! cuid, key, iid, _ = CClient.extract_ajax req res in
    
    let! () = ohm begin match cuid with 
      | None -> return () 
      | Some cuid -> MDigest.Subscription.unsubscribe cuid iid 
    end in
    
    respond cuid key iid res

end
