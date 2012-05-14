(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let follow_reaction cuid iid = 
  O.Box.reaction "follow" begin fun self bctx _ response ->

    let! follows = ohm $ MDigest.Subscription.follows cuid iid in
    
    let! () = ohm begin 
      if follows then
	MDigest.Subscription.unsubscribe cuid iid
      else
	MDigest.Subscription.subscribe cuid iid
    end in 

    return $ O.Action.javascript (JsBase.boxRefresh 0.0) response

  end

let box ~i18n ~user = 
  O.Box.leaf begin fun _ _ -> 
    let  uid     = IUser.Deduce.current_is_anyone user in 
    let! did     = ohm $ MDigest.OfUser.get uid in 
    let! summary = ohm $ MDigest.get_summary_for_showing did in
    
    let render_next (bid,time,title) = object
      method url   = UrlBroadcast.link # build bid 
      method time  = time
      method title = title 
    end in

    let render_instance (iid,content) = 
      let! instance = ohm_req_or (return None) $ MInstance.get iid in 
      let! pic      = ohm $ CPicture.small (instance # pic) in 
      let! via      = ohm begin 
	match content # first # forward with None -> return None | Some fwd -> 
	  let! instance = ohm_req_or (return None) $ MInstance.get (fwd # from) in 
	  let  url      = UrlR.home # build instance in  
	  return $ Some (url, instance # name)
      end in 

      let from_url = UrlR.home # build instance in 
      let title, body, rss = match content # first # content with
	| `Post p -> p # title, VText.format (p # body), None
	| `RSS  r -> r # title, OhmSanitizeHtml.html (r # body), Some (r # link) 
      in

      return $ Some (object
	method from_pic = pic
	method from     = instance # name
	method from_url = from_url
	method via      = via 
	method url      = UrlBroadcast.link # build (content # first # id) 
	method time     = content # first # time
	method text     = body
	method title    = title
	method next     = List.map render_next (content # next)
	method rss      = rss
      end)
    in

    let! items = ohm $ Run.list_filter render_instance summary in 

    return $ VDigest.Page.render (object
      method list = items
      method more = I18n.translate i18n (`label "show-details")
    end) i18n 
  end

(* Block notifications from digests *)

let () = CCore.register UrlBroadcast.unsubscribe begin fun i18n request response -> 

  let fail = 
    let title = `label "digest.unsubscribe.fail" in
    let body  = return $ VDigest.UnsubscribeFail.render title i18n in
    CCore.render (return (I18n.get i18n title)) body response
  in

  let! uid = req_or fail $ request # args 0 in
  let  uid = IUser.of_string uid in

  let! proof = req_or fail $ request # args 1 in

  let! uid = req_or fail $ IUser.Deduce.from_block_token proof uid in
  
  match request # args 2 with 
    | Some "confirm" -> begin

      let! () = ohm $ MUser.block uid ~blocked:[`digest] in

      let title = `label "digest.unsubscribe.ok" in
      let body  = return $ VDigest.UnsubscribeOk.render title i18n in
      CCore.render (return (I18n.get i18n title)) body response

    end

    | _ ->  begin

      let url = UrlBroadcast.unsubscribe # build_confirm uid in

      let title = `label "digest.unsubscribe" in
      let body  = return $ VDigest.Unsubscribe.render (title,url) i18n in
      CCore.render (return (I18n.get i18n title)) body response

    end
  
end
