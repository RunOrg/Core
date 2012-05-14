(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

(* Grab all active chat rooms and render them as a block. *)

let all_active ~ctx = 
  let! list = ohm $ MChat.Room.all_active (ctx # iid) in
  let! rendered = ohm $ Run.list_filter begin fun fid -> 
    let! feed = ohm_req_or (return None) $ MFeed.try_get ctx fid in 
    let! feed = ohm_req_or (return None) $ MFeed.Can.write feed in
    match MFeed.Get.owner feed with
      | `of_message   _  -> return None
      | `of_instance iid -> 
	let! pic = ohm $ CPicture.small (ctx # instance # pic) in
	return (Some (`text (ctx # instance # name), pic, 
		      UrlChat.instance (ctx # instance) None)) 
      | `of_entity   eid -> 
	let! entity = ohm_req_or (return None) $ MEntity.try_get ctx eid in 
	let! entity = ohm_req_or (return None) $ MEntity.Can.view entity in 
	let! pic    = ohm $ CPicture.small (MEntity.Get.picture entity) in
	let  name   = CName.of_entity entity in 
	return (Some (name, pic,
		      UrlChat.entity (ctx # instance) eid None))	    
  end list in 
  if rendered = [] then return identity else
    return $ VChat.Active.render rendered (ctx # i18n)

(* Rendering the chatroom itself *)

let render_avatar ctx aid = 
  let! details = ohm $ MAvatar.details aid in 
  let! pic     = ohm $ CPicture.small (details # picture) in
  let  name    = CName.get (ctx # i18n) details in
  return (object
    method id   = IAvatar.decay aid
    method name = name
    method pic  = pic
  end)

(* TODO *)
let not_found ~ctx = O.Box.leaf begin fun _ _ -> return identity end

let user_reaction ~ctx = 
  O.Box.reaction "user" begin fun _ bctx _ response -> 

    let  finish = return response in 
    
    let! aid = req_or finish $ IAvatar.of_json_safe (bctx # json) in
    
    let! details = ohm $ render_avatar ctx aid in 

    return $ O.Action.json [ "user", VChat.AvatarFmt.to_json details ] response
	
  end

let post_reaction ~ctx crid = 
  O.Box.reaction "post" begin fun _ bctx _ response -> 
    
    let  finish = return response in 
    
    let! text = req_or finish $ Fmt.String.of_json_safe (bctx # json) in
    let  text = BatString.strip text in 
    let  text = if String.length text > 3000 then String.sub text 0 3000 else text in 
    let!  ()  = true_or finish (text <> "") in
    
    let! self = ohm $ ctx # self in 

    let payload = `text MChat.Line.({
      text_author   = IAvatar.decay self ;
      text_contents = text ; 
      text_time     = Unix.gettimeofday () 
    }) in

    let!  ()  = ohm $ MChat.post crid payload self in

    let! last, _ = ohm $ MChat.Feed.list ~count:5 crid in

    return $ O.Action.json [ "chat", Json_type.Build.list MChat.Line.to_json last ] response
	
  end

let ensure_reaction ~ctx crid = 
  O.Box.reaction "ensure" begin fun _ bctx _ response -> 
    
    let finish = return response in 

    let! self = ohm $ ctx # self in

    let!  ()  = ohm $ MChat.Room.ensure crid in
    let! url  = ohm_req_or finish $ MChat.url crid self in 

    return $ O.Action.json [ "chat", Json_type.String url ] response
	
  end

let post_box ~ctx crid = 
  let! post = post_reaction ~ctx crid in 
  let! user = user_reaction ~ctx in
  let! ensure = ensure_reaction ~ctx crid in  
  O.Box.leaf begin fun bctx _ ->
    let! others  = ohm $ all_active ~ctx in
    let! self    = ohm $ ctx # self in 
    let! chat    = ohm $ MChat.url crid self in 
    let! last, _ = ohm $ MChat.Feed.list ~count:20 crid in
    let! avatar  = ohm $ render_avatar ctx self in 
    return $ VChat.Post.render (object
      method post = bctx # reaction_url post
      method user = bctx # reaction_url user
      method last = last
      method ensure = bctx # reaction_url ensure  
      method chat = BatOption.default "" chat  
      method self = avatar
      method active = others 
    end) (ctx # i18n) 
  end

let download_reaction ~ctx crid = 
  O.Box.reaction "download" begin fun _ bctx _ response -> 

    let! last, next = ohm $ MChat.Feed.list ~reverse:true ~count:1000 crid in

    let avatar_info = Util.memoize begin fun aid -> Run.memo (
      let! details = ohm $ MAvatar.details aid in 
      let  name    = CName.get (ctx # i18n) details in 
      return (name, UrlProfile.page ctx aid, Hashtbl.hash aid)
    ) end in 

    let! text = ohm $ Run.list_map begin fun item -> 
      let  `text t = MChat.Line.payload item in 
      let! name, url, color = ohm $ avatar_info t.MChat.Line.text_author in
      let  time = Unix.gmtime t.MChat.Line.text_time in
      return (object
	method hour   = time.Unix.tm_hour 
	method minute = time.Unix.tm_min
	method name   = name
	method text   = t.MChat.Line.text_contents
      end)
    end last in 

    let data = VChat.Download.render (object
      method text = text
    end) (ctx # i18n) in
	
    return (
      O.Action.file ~file:"chat.doc" ~mime:"application/msword" ~data response
    )

  end

let view_box ~ctx crid = 
  let! download = download_reaction ~ctx crid in 
  O.Box.leaf begin fun bctx _ ->
    let! last, next = ohm $ MChat.Feed.list ~reverse:true ~count:1000 crid in

    let avatar_info = Util.memoize begin fun aid -> Run.memo (
      let! details = ohm $ MAvatar.details aid in 
      let  name    = CName.get (ctx # i18n) details in 
      return (name, UrlProfile.page ctx aid, Hashtbl.hash aid)
    ) end in 

    let! text = ohm $ Run.list_map begin fun item -> 
      let  `text t = MChat.Line.payload item in 
      let! name, url, color = ohm $ avatar_info t.MChat.Line.text_author in
      return (object
	method date  = t.MChat.Line.text_time
	method name  = name
	method text  = t.MChat.Line.text_contents
	method url   = url
	method color = color
      end)
    end last in 

    return $ VChat.View.render (object
      method back  = UrlR.wall # build (ctx # instance)
      method file  = bctx # reaction_url download
      method text = text
    end) (ctx # i18n) 
  end

let box ~ctx ~wall = 
  O.Box.decide begin fun _ (_,chat_opt) -> 
    match chat_opt with 
      | None      -> let! wall = ohm_req_or (return $ not_found ~ctx) $
		       MFeed.Can.write wall in 
		     let! crid, _ = ohm $ MChat.Room.recent wall in
		     return $ post_box ~ctx crid
      | Some crid -> let! crid = ohm_req_or (return $ not_found ~ctx) $ 
		       MChat.Room.readable crid (MFeed.Get.id wall) in
		     return $ view_box ~ctx crid  
  end
  |> O.Box.parse UrlSegs.chat_id

