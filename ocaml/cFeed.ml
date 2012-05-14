(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

class ['a] cache (_ctx : 'a CContext.full) = object (self)

  val feed_owner = memoize (fun fid -> 
    Run.memo (let! feed  = ohm_req_or (return None) $ MFeed.try_get _ctx fid in 
	      return $ Some (MFeed.Get.owner feed)))

  method feed_owner (feed : [`Unknown] IFeed.id) =
    ( (feed_owner feed) : [ `of_instance of IInstance.t 
			  | `of_entity   of IEntity.t 
			  | `of_message  of IMessage.t ] option O.run)

  val ctx = _ctx
  method ctx = ctx

  val details = memoize (fun aid -> Run.memo (MAvatar.details aid))
  method details (avatar : IAvatar.t) = details avatar

  method picture pic = self # ctx # picture_small pic

  val entity = memoize (fun eid -> 
    Run.memo (let! entity = ohm $ MEntity.try_get _ctx eid in
	      Run.opt_bind MEntity.Can.view entity))
  method entity (eid : IEntity.t) = entity eid

  val message_title = memoize (fun mid ->
    Run.memo (MMessage.get_title ~ctx:_ctx mid))
  method message_title (mid : IMessage.t) = 
    ( (message_title mid) : [`Forbidden | `None | `Some of string] O.run)

end

let make_cache ctx = new cache ctx

module CWall = struct

  let render_item (cache : 'a cache) (item : MItem.item) = 

    let i18n = cache # ctx # i18n in 

    let! view = ohm_req_or (return None) begin

      match item # where with 
	| `album _ 
	| `folder _ -> return None
	| `feed feed -> 
	  
	  let! owner = ohm (cache # feed_owner feed) in
	  match owner with 
	    | None 
	    | Some (`of_instance _) ->

	      let item_url = UrlR.wall # build (cache # ctx # instance) in
	      return (Some (VFeed.Wall.item ~item_url))

		
	    | Some (`of_message mid) ->
	      
	      let! title = ohm $ cache # message_title mid in
	      begin match title with  
		| `Forbidden | `None -> return None 
		| `Some message_name -> 
		  let message_url  = UrlMessage.build (cache # ctx # instance) mid in
		  return $ Some (VFeed.Wall.item_message ~message_url ~message_name)
	      end
		  
	    | Some (`of_entity eid) -> 
	     
	      let! entity = ohm_req_or (return None) $ cache # entity eid in
	      let entity_name = CName.of_entity entity in
	      let entity_url  = UrlEntity.discussion (cache # ctx # instance) eid in
	      return $ Some (VFeed.Wall.item_entity ~entity_url ~entity_name)
    end in

    let icon = match item # payload with 
      | `Message  _ -> VIcon.user_comment
      | `MiniPoll _ -> VIcon.chart_bar
      | `Image    _ -> VIcon.picture
      | `Chat     _ -> VIcon.comments
      | `ChatReq  _ -> VIcon.comments_add
      | `Doc      d -> VIcon.of_extension (d # ext) 
    in
    
    let! author = req_or (return None) $ MItem.author (item # payload) in
    let  url     = UrlProfile.page (cache # ctx) author in
    let! details = ohm $ cache # details author in
    let! pic     = ohm $ cache # picture (details # picture) in
    let  name    = CName.get i18n details in      

    let date = item # time in
    
    let! text = req_or (return None) begin match item # payload with 
      | `Message  m -> Some (m # text) 
      | `MiniPoll p -> Some (p # text) 
      | `ChatReq  _ 
      | `Image    _ 
      | `Chat     _ 
      | `Doc      _ -> None
    end in 

    return $ Some (view ~url ~pic ~name ~icon ~date ~text ~i18n)    
	      	
end

module CJoin = struct

  let render_join cache join = 
    let i18n = cache # ctx # i18n in 

    let! entity = ohm_req_or (return None) (cache # entity (join # e)) in

    let! details    = ohm (cache # details (join # a)) in
    
    let entity_name = CName.of_entity entity in 
    let entity_url  = (UrlEntity.root ()) # build (cache # ctx # instance) (join # e) in 
    let date        = join # t in 
    let name        = CName.get i18n details in 
    let url         = UrlProfile.page (cache # ctx) (join # a) in 

    let render = match join # s with 
      | `invited by -> 
	
	let! by_details = ohm (cache # details by) in
	let by_name = CName.get i18n by_details in 
	let by_url  = UrlProfile.page (cache # ctx) by in 
	return (VFeed.Join.invited ~by_name ~by_url)

      | `denied ->

	return (VFeed.Join.declined) 

      | `added None -> 

	return (VFeed.Join.self_added) 

      | `added (Some by) -> 

	let! by_details = ohm (cache # details by) in
	let by_name = CName.get i18n by_details in 
	let by_url  = UrlProfile.page (cache # ctx) by in 
	return (VFeed.Join.added ~by_name ~by_url)

      | `requested ->
	
	return (VFeed.Join.requested)

      | `removed None ->
	
	return (VFeed.Join.self_removed)

      | `removed (Some by) ->

	let! by_details = ohm (cache # details by) in
	let by_name = CName.get i18n by_details in 
	let by_url  = UrlProfile.page (cache # ctx) by in 
	return (VFeed.Join.removed ~by_name ~by_url)
    in

    let! render = ohm render in

    return (Some (render ~entity_name ~entity_url ~date ~name ~url ~i18n))
	
end

(* Render elements based on their type *)

let render cache = function
  | `item iid  -> let! item = ohm_req_or (return None) $ MItem.try_get (cache # ctx) iid in
		  CWall.render_item cache item
  | `join join -> CJoin.render_join cache join 

(* The main association feed *)

module DetailsFeed = struct

  let more_arg  = "t"

  let get ~ctx ~bctx ~more ~empty start = 
    
    let cache = make_cache ctx in

    let iid = IInstance.decay (ctx # iid) in
    let not_avatar = BatOption.map IAvatar.decay (ctx # self_if_exists) in

    let! feed, next = ohm
      (MNews.List.by_instance ~ctx ~instance:iid ~not_avatar start) 
    in

    let! feed = ohm $ Run.list_filter (render cache) feed in
        
    let next = next |> BatOption.map begin fun next -> 
      Js.More.fetch ~args:[ more_arg, Json_type.Build.float next ] (bctx # reaction_url more)
    end in
    
    return (
      if feed = [] then empty (ctx # i18n) else
	VFeed.more ~feed ~next ~i18n:(ctx # i18n)
    )
          
  let more ~ctx =
    O.Box.reaction "feed-more" begin fun self bctx url response ->
  
      let respond html = Action.json (Js.More.return html) response in 
      let fail = respond identity in
      
      let start = 
	try BatOption.map float_of_string (bctx # post more_arg) 
	with _ -> None
      in
      
      if BatOption.is_some start then 
	get ~ctx ~bctx ~more:self ~empty:(fun i c -> c) start |> Run.map respond
      else
	return fail
    end

end

let home_box ~ctx = 

  let! react_more = DetailsFeed.more ~ctx in

  O.Box.leaf begin fun bctx url -> 
    DetailsFeed.get ~ctx ~bctx ~more:react_more ~empty:VFeed.empty None 
  end

