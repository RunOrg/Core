(* © 2012 RunOrg *)

open Ohm
open O
open BatPervasives
open Ohm.Universal
open Ohm.Util

module Attach = CItem_attach

type config = <
  react : bool ;
  chat  : [`View] IChat.Room.id option -> string option 
>

(* Prepending the url info to a base URL *)
let make_url ctx segments data iid = 
  let segments = O.Box.Seg.(segments ++ CSegs.item_or_list) in
  let data = data, `Item (IItem.decay iid) in
  UrlR.build (ctx # instance) segments data

(* Find the URL of an item based on its data *)
let item_url ctx item iid = 
  match item # where with 
    | `folder folder -> 

      let! folder = ohm_req_or (return None) (MFolder.try_get ctx folder) in
      let! entity = req_or (return None) (MFolder.Get.entity folder) in
      
      let segments, data  = 
	O.Box.Seg.(UrlEntity.segments ++ CSegs.entity_tabs),
	((((),`Entity),Some entity),`Folder)
      in
	
      return (Some (make_url ctx segments data iid))

    | `album  album  ->
  
      let! album  = ohm_req_or (return None) (MAlbum.try_get ctx album) in
      let! entity = req_or (return None) (MAlbum.Get.entity album) in
      
      let segments, data = 
	O.Box.Seg.(UrlEntity.segments ++ CSegs.entity_tabs),
	((((),`Entity),Some entity),`Album)
      in

      return (Some (make_url ctx segments data iid))

    | `feed   feed   -> 

      let! feed  = ohm_req_or (return None) (MFeed.try_get ctx feed) in
      match MFeed.Get.owner feed with 

	| `of_message mid -> return (Some (UrlMessage.build (ctx # instance) mid))

	| `of_instance  _ -> 
	  
	  let segments, data = 
	    O.Box.Seg.(root ++ CSegs.root_pages ++ CSegs.home_pages), 
	    (((),`Home),`Wall)
	  in
	  return (Some (make_url ctx segments data iid))
	
	| `of_entity   eid ->

	  let segments, data = 
	    O.Box.Seg.(UrlEntity.segments ++ CSegs.entity_tabs),
	    ((((),`Entity),Some eid),`Wall)
	  in
	  
	  return (Some (make_url ctx segments data iid))

(* Find the URL of an item based on its identifier *)

let url ctx iid = 

  let! item = ohm_req_or (return None) (MItem.try_get ctx iid) in
  
  item_url ctx item iid 

(* Is an item liked by a given avatar? *)
 
let liked myAvatar item =
  if List.mem (IAvatar.decay myAvatar) (item # clike) then return true else 
    if List.length (item # clike) = (item # nlike) then return false else
      MLike.likes myAvatar (`item (item # id))

(* Extracts information about a reply to an item *) 

let reply ctx id = 
  
  let! reply   = ohm_req_or (return None) $ MComment.get id in
  let! details = ohm (MAvatar.details (reply # who)) in
  let! pic     = ohm (CPicture.small (details # picture)) in
  let  name    = CName.get (ctx # i18n) details in    
    
  return $ Some begin 
    new VWall.reply 
      ~pic
      ~url:(UrlProfile.page ctx reply # who)
      ~name
      ~text:(reply # what)
      ~date:(reply # time)
      ~role:None
  end

(* Crete an item renderer *)      
let renderer ~from ~config ~(ctx:'any CContext.full) = 

  let self_opt = ctx # self_if_exists in
  let instance = ctx # instance in 
  let i18n     = ctx # i18n in
  let cuid     = ctx # cuid in 

  let render_authored ~author ?(text="") ~kind ~attach (item:MItem.item) = 

    let riid = IItem.Deduce.read_can_reply (item # id) in
    let liid = IItem.Deduce.read_can_like  (item # id) in

    let! avatar = ohm $ MAvatar.details author in
    let  name   = CName.get i18n avatar in
    let! pic    = ohm (CPicture.small (avatar # picture)) in

    (* The author of this element *)
    let liked  = match self_opt with 
      | None      -> return false
      | Some self -> liked self item
    in

    (* Has the viewer liked this element ? *)
    let! liked = ohm liked in

    let id = Id.gen () in
    
    let more = 
      if List.length (item # ccomm) < item # ncomm then 
	Some ((UrlWall.more_replies ()) # build instance cuid (item # id))
      else None
    in

    let remove = match item # own with 
	
      (* We own the item, so we can remove it. *)
      | Some own -> let rmiid = IItem.Deduce.own_can_remove own in 
		    Some ((UrlWall.remove ()) # build instance cuid rmiid)
		      
      | None -> let id = IItem.decay (item # id) in
		match from with 
		    
		  (* We own the feed, so we can remove the item. *)
		  | Some (`feed feed) -> 
		    Some (UrlWall.moderate # build instance feed id)
		      
		  (* We own the album, so we can remove the item. *)
		  | Some (`album album) ->
		    Some (UrlAlbum.moderate # build instance album id) 
		      
		  (* We own the folder, so we can remove the item. *)
		  | Some (`folder folder) ->
		    Some (UrlFolder.moderate # build instance folder id)
		      
		  (* We own neither item nor feed, so no removal! *)
		  | None -> None
    in
    
    (* Parse and pre-render all replies to this object. *)
    let! replies = ohm (
      item # ccomm |> Run.list_filter (reply ctx)
    ) in

    let data = new VWall.item 
	~id
	~url:(UrlProfile.page ctx author) 
	~pic
	~name
	~text
	~liked
	~likes:(item # nlike) 
	~like:((UrlWall.like_item ()) # build instance cuid liid) 
	~reply:((UrlWall.reply ()) # build instance id cuid riid) 
	~replies:(List.rev replies)
	~more
	~remove
	~react:(config # react)
	~date:(item # time)
	~kind
	~attach
	~role:None
    in

    return $ VWall.Item.render data i18n

  in

  let render_message item message = 
    render_authored 
      ~author:(message # author)
      ~text:(message # text)
      ~kind:`none
      ~attach:identity 
      item 
  in

  let render_poll item poll = 
    let  pid = poll # poll in
    let! attach = ohm $ Attach.poll ctx pid in 
    render_authored
      ~author:(poll # author) 
      ~text:(poll # text)
      ~kind:`poll
      ~attach
      item
  in

  let render_image item image = 
    render_authored 
      ~author:(image # author) 
      ~kind:`image
      ~attach:identity (* TODO *)
      item 
  in

  let render_doc item doc = 

    let! attach = ohm begin 
      let! download = ohm_req_or (return identity)
	(MFile.Url.get (doc # file) `File) in
      
      let attach_data = object 
	method download = download
	method title    = doc # title
	method size     = doc # size
      end in
      
      return $ VFolder.Attached.render attach_data i18n 
    end in 

    render_authored
      ~author:(doc # author) 
      ~kind:(`doc (doc # ext)) 
      ~attach
      item
  in 

  let render_chat item chat = 

    let id  = Id.gen () in
    let crid = chat # room in 

    let! lines = ohm $ MChat.Feed.count crid in 
    let! participants = ohm $ MChat.Participant.count crid in 

    let! avatars, _ = ohm $ MChat.Participant.list ~count:11 crid in 

    let! avatars = ohm $ Run.list_map begin fun aid -> 
      let! details = ohm $ MAvatar.details aid in 
      let! pic     = ohm $ CPicture.small (details # picture) in
      let  name    = CName.get i18n details in
      return (name, pic)
    end avatars in 

    let! active_crid_opt = ohm $ MChat.Room.active crid in 

    let! url, label = req_or (return identity) begin match active_crid_opt with 
      | Some _ -> let! url   = req_or None $ config # chat None in
		  let  label = `label "item.chat.participate" in
		  Some (url, label) 
      | None   -> let! url   = req_or None $ config # chat (Some crid) in
		  let  label = `label "item.chat.view" in
		  Some (url, label)
    end in
  
    let data = new VWall.chat_item     
      ~id
      ~date:(item # time)
      ~url
      ~avatars
      ~lines
      ~participants
      ~label
    in
    
    return $ VWall.ChatItem.render data i18n 

  in 

  let render_chatreq item req = 

    let! chat    = req_or (return identity) $ config # chat None in

    let  id      = Id.gen () in

    let! avatar  = ohm $ MAvatar.details (req # author) in
    let  name    = CName.get i18n avatar in
    let! picture = ohm (CPicture.small (avatar # picture)) in
    let  url     = UrlProfile.page ctx (req # author) in

    let data = new VWall.chat_request_item     
      ~id
      ~date:(item # time)
      ~url
      ~picture
      ~name
      ~chat
      ~topic:(req # topic)
    in
    
    return $ VWall.ChatRequestItem.render data i18n 

  in 

  fun ( item : MItem.item ) ->

    match item # payload with 
      | `Message  m -> render_message item m
      | `MiniPoll p -> render_poll    item p 
      | `Image    i -> render_image   item i 
      | `Doc      d -> render_doc     item d 
      | `Chat     c -> render_chat    item c 
      | `ChatReq  r -> render_chatreq item r

(* Display an item in a wrapper ---------------------------------------------------------- *)

let display ~ctx ~from ~config ~item =
  renderer ~from ~config ~ctx item 
