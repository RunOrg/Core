(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

module Post    = CWall_post
module Follow  = CWall_follow
module Like    = CWall_like
module NewChat = CWall_newChat

(* Extracting the list ...  ----------------------------------------------------------------- *)

let fetch_list ?start ~config ~(ctx:'any CContext.full) ~feed more =
 
  let self_opt = ctx # self_if_exists in

  let! items, last = ohm $ MItem.list 
    ?self:self_opt 
    (`feed (IFeed.Deduce.can_read (MFeed.Get.id feed)))
    ~count:7 
    start
  in

  let! own_feed = ohm (MFeed.Can.admin feed) in

  let from = BatOption.map 
    (fun feed -> `feed (MFeed.Get.id feed)) own_feed in
  
  let renderer = CItem.renderer ~from ~ctx ~config in 
  
  let more = match last with None -> None | Some time ->
    Some (Js.More.fetch ~args:["before",Json_type.Float time] more) 
  in
  
  Run.list_map renderer items |> Run.map (fun list -> list, more)

(* "More" link ------------------------------------------------------------------------------ *)

let more ~(ctx:'any CContext.full) ~config ~feed = 
  O.Box.reaction "more-items" begin fun self input url response ->
    
    let i18n = ctx # i18n in
    let fail = return (O.Action.json (Js.More.return (View.str "")) response) in
        
    let start_opt = 
      try match input # post "before" with
	| None     -> None
	| Some str -> Some (float_of_string str)
      with _ -> None
    in
    
    let! start = req_or fail start_opt in
    
    let reaction = input # reaction_url self in

    let! (list,more) = ohm
      (fetch_list ~start ~ctx ~feed ~config reaction) in
    
    let data = object
      method list = list
      method more = more
    end in
    
    return (
      O.Action.json (Js.More.return (VWall.More.render data i18n)) response
    )   
      
  end

(* Creating a new poll... ------------------------------------------------------------------- *)

module NewPoll = struct

  module Fields = FPoll.Create.Fields
  module Form   = FPoll.Create.Form

  let display ~ctx ~i18n ~post =
    O.Box.reaction "new-poll" begin fun self input url response ->
      let title = I18n.translate i18n (`label "wall.new-poll") in
      let body  = VWall.Poll.New.render (object 
	method url  = input # reaction_url post 
	method init = FPoll.Create.Form.empty
      end) i18n in
      return $ O.Action.javascript (Js.Dialog.create body title) response
    end
	      
  let create ~(ctx:'any CContext.full) ~config ~i18n ~feed ~feed_hid = 
    O.Box.reaction "new-poll-create" begin fun self input url response ->
      
      let _q = [0;1;2;3;4;5] in
      
      let text      = ref None 
      and multiple  = ref None
      and questions = Array.init (List.length _q) (fun _ -> ref None) in
      
      let form = Form.readpost (input # post) 
        |> Form.optional `Text     Fmt.String.fmt text 
        |> Form.optional `Multiple Fmt.Bool.fmt   multiple
      in

      let form = 
	List.fold_left (fun form i -> Form.optional (`Answer i)
	  Fmt.String.fmt questions.(i) form) form _q
      in
      
      let earlyout = O.Action.json (Form.response form) response in
      
      let text     = match !text     with None -> "" | Some text -> BatString.trim text in
      let multiple = match !multiple with Some b -> b | None -> false in
      
      let questions = BatList.filter_map (fun x -> !x) (Array.to_list questions) in
      
      if text = "" || questions = [] then return earlyout else      
	
	let user = IIsIn.user (ctx # myself) in 
	let instance = ctx # myself |> IIsIn.instance |> IInstance.decay in
	
	let! poll = ohm $ MPoll.create (object
	  method questions = List.map (fun x -> `text x) questions
	  method multiple  = multiple
	end ) in
	
	let! self = ohm $ ctx # self in
	    
	let! itid = ohm $ MItem.Create.poll self text poll instance (MFeed.Get.id feed) in
	    	      
	let  riid = IItem.Deduce.created_can_reply  itid in
	let  liid = IItem.Deduce.created_can_like   itid in
	let rmiid = IItem.Deduce.created_can_remove itid in
	
	let! details = ohm $ MAvatar.details self in
	let  name    = CName.get (ctx # i18n) details in 
	let! pic     = ohm $ ctx # picture_small (details # picture) in
		  
	let! attach = ohm $ CItem.Attach.poll ctx (IPoll.Deduce.created_can_read poll) in
		    
	let id = Id.gen () in            
	
	let data = new VWall.item 
	  ~id
	  ~url:(UrlProfile.page ctx self)
	  ~pic
	  ~name
	  ~text
	  ~liked:false
	  ~likes:0
	  ~like:((UrlWall.like_item ()) # build (ctx # instance) user liid)
	  ~reply:((UrlWall.reply ()) # build (ctx # instance) id user riid) 
	  ~replies:[]
	  ~remove:(Some ((UrlWall.remove ()) # build (ctx # instance) user rmiid))
	  ~react:(config # react)
	  ~date:(Unix.gettimeofday ())
	  ~role:None
	  ~more:None
	  ~kind:`poll
	  ~attach
	in
	
	let code = JsCode.seq [
	  Js.Dialog.close ;
	  Js.wallPost feed_hid (VWall.Item.render data i18n)
	] in
	
	return $ O.Action.javascript code response
	  
    end

end

(* Display the box -------------------------------------------------------------------------- *)

let n_box ~i18n = 
  O.Box.leaf (fun input _ -> return (VWall.N.render () i18n))

let r_box ~(ctx:'any CContext.full) ~feed ~config ~i18n =
  let config = object
    method react = false
    method chat  = config # chat
  end in
  let! more = more ~ctx ~feed ~config in 
  O.Box.leaf begin fun input _ ->    	 

    let reaction = input # reaction_url more in

    let! (list,more) = ohm
      (fetch_list ~ctx ~feed ~config reaction) in

    return (
      VWall.R.render (object 
	method list = list
	method more = more
      end) i18n 
    )
  end

let rw_box ~(ctx:'any CContext.full) ~(feed:[`Write] MFeed.t) ~config ~i18n = 

  let feed_hid  = Id.of_string "the_feed" in
  let! new_poll_post = NewPoll.create  ~ctx ~feed ~feed_hid ~config ~i18n in
  let! new_poll      = NewPoll.display ~ctx ~i18n ~post:new_poll_post in
  let! new_chat      = NewChat.create  ~ctx ~feed in
  let! new_post      = Post.create     ~ctx ~feed ~feed_hid ~config in
  let! follow        = Follow.reaction ~ctx ~feed in
  let! more          = more ~ctx ~feed ~config in

  O.Box.leaf begin fun bctx url ->  

    let reaction = bctx # reaction_url more in

    let! (list,more) = ohm
      (fetch_list ~ctx ~feed ~config reaction) in

    let! blocked = ohm (match ctx # self_if_exists with 
      | None      -> return true
      | Some self -> MBlock.is_blocked self (`Feed (IFeed.decay (MFeed.Get.id feed)))
    ) in
   
    let post_actions = object
      method title   = Some (`label "wall.actions.post")
      method actions = [ 
	`Button (object
	  method label = `label "wall.new-poll"
	  method js    = Js.runFromServer (bctx # reaction_url new_poll)
	  method img   = VIcon.chart_bar_add
	end) ]
      @ ( if config # chat None = None then [] else  
	  [ `Button (object
	    method label = `label "wall.new-chat"
	    method js    = Js.runFromServer (bctx # reaction_url new_chat) 
	    method img   = VIcon.comments_add
	  end) ] )
    end in 

    let follow_actions = object
      method title   = None
      method actions = [
	`Button (Follow.render_action blocked (bctx # reaction_url follow))
      ]
    end in 

    let! chatrooms = ohm $ CChat.all_active ~ctx in

    return (
      VWall.RW.render (object
	method post_url  = bctx # reaction_url new_post 
	method post_init = FWall.Post.Form.empty 
	method actions   = fun i c -> c 
	  |> VCore.ActionBox.render follow_actions i
          |> VCore.ActionBox.render post_actions   i
	  |> chatrooms
 	method id        = feed_hid
	method list      = list
	method more      = more
      end) i18n 
    )
  end

let list_url ctx input prefix = 
  UrlR.build (ctx # instance) (input # segments) (prefix, `List)

let item_box ~ctx ~wall ~config ~item = 
  O.Box.leaf begin fun bctx (prefix,_) ->

    let back = list_url ctx bctx prefix in

    let result render = 
      return (VWall.ShowItem.render (object
	method contents = render
	method back     = back
      end) (ctx # i18n))
    in
    
    let missing = result (VWall.Missing.render () (ctx # i18n)) in

    let! from = ohm $ MFeed.Can.admin wall in
    let  from = BatOption.map (fun feed -> `feed (MFeed.Get.id feed)) from in
    
    let! item = ohm_req_or missing (MItem.try_get ctx item) in

    let! render = ohm (CItem.display ~ctx ~from ~config ~item) in

    result render

  end

let full_nested_box ~(ctx:'any CContext.full) ~config ~wall = 
  let i18n = ctx # i18n in 
  O.Box.decide begin fun _ (_,what) ->

    match what with 
      | `List -> begin
	let! feed_opt = ohm $ MFeed.Can.write wall in
	match feed_opt with Some feed -> return $ rw_box ~ctx ~feed ~config ~i18n | None -> 
	  let! feed_opt = ohm $ MFeed.Can.read wall in
	  match feed_opt with Some feed -> return $ r_box  ~ctx ~feed ~config ~i18n | None -> 
	    return $ n_box ~i18n:(ctx # i18n)
	end
      | `Item item -> return $ item_box ~ctx ~wall ~config ~item
  end
  |> O.Box.parse CSegs.item_or_list
    

(* Reply pop-up ----------------------------------------------------------------------------- *)

module Reply = struct

  module Form   = FWall.Reply.Form
  module Fields = FWall.Reply.Fields

  let () = CClient.User.register CClient.is_contact (UrlWall.post_reply ()) 
    begin fun ctx request response ->

      let i18n = ctx # i18n in

      (* Read the sent data *)
      let text = ref None in 
      let form = Form.readpost (request # post) |> Form.optional `Text Fmt.String.fmt text in

      let empty = O.Action.json (Form.response form) response in	

      let! text = req_or (return empty) $ BatOption.map BatString.strip !text in 
      
      if text = "" then return empty else 

	(* Text was sent, try posting it *)
	let fail = 
	  let title = I18n.translate i18n (`label "wall.reply.title") in
	  let body = VWall.ReplyForbidden.render () i18n in
	  O.Action.javascript (Js.Dialog.create body title) response
	in

	let! divid = req_or (return fail) (request # args 0) in
	let  divid = Id.of_string divid in 

	let! item  = req_or (return fail) (request # args 1) in
	let  item  = IItem.of_string  item in

	let! proof = req_or (return fail) (request # args 2) in

	let  cuid  = ctx # cuid in 
	
	let! item  = req_or (return fail) 
	  (IItem.Deduce.from_reply_token cuid item proof)
	in
	
	let! self = ohm $ ctx # self in
	
	let! _ = ohm $ MComment.create item self text in
	
	let! details = ohm $ MAvatar.details self in
	
	(* Text was posted, send back some HTMLish goodness *)
	
	let name    = CName.get i18n details in
	let! pic = ohm $ CPicture.small (details # picture) in
	
	let data = new VWall.reply 
	  ~pic
	  ~url:(UrlProfile.page ctx self) 
	  ~name
	  ~text
	  ~date:(Unix.gettimeofday ())
	  ~role:None
	in
	
	let html = VWall.Reply.render data i18n in
	
	let code = JsCode.seq [
	  Js.appendReply divid html ;
	  Js.Dialog.close
	] in
	
	return $ O.Action.javascript code response
	  
    end

  let () = CClient.User.register CClient.is_contact (UrlWall.reply ())
    begin fun ctx request response ->
      
      let i18n  = ctx # i18n in
      let title = I18n.translate i18n (`label "wall.reply.title") in

      let fail = 
	let body = VWall.ReplyForbidden.render () i18n in
	O.Action.javascript (Js.Dialog.create body title) response
      in

      let! id    = req_or (return fail) (request # args 0) in
      let  id    = Id.of_string id in 

      let! item  = req_or (return fail) (request # args 1) in 
      let  item  = IItem.of_string item in

      let! proof = req_or (return fail) (request # args 2) in

      let  user  = IIsIn.user (ctx # myself) in
      
      let! item  = 
	req_or (return fail) 
	  (IItem.Deduce.from_reply_token user item proof)
      in
      
      let body  = 
	VWall.ReplyForm.render (object 
	  method url  = (UrlWall.post_reply ()) # build (ctx # instance) id user item
	  method init = Form.empty
	end) i18n
      in
	
      return (O.Action.javascript (Js.Dialog.create body title) response)

    end
end

(* Removal --------------------------------------------------------------------------------- *)

module Remove = struct

  let () = CClient.User.register CClient.is_contact (UrlWall.remove ())
    begin fun ctx request response ->
      
      let fail = return (O.Action.javascript Js.panic response) in

      let! item = req_or fail (request # args 0) in
      let item = IItem.of_string item in 

      let! proof = req_or fail (request # args 1) in
      
      let user  = IIsIn.user (ctx # myself) in
      
      let! rmiid = req_or fail
	  (IItem.Deduce.from_remove_token user item proof) in

      let! () = ohm (MItem.Remove.delete rmiid) in
      return (O.Action.javascript (Js.removeParent ".wall-item, .album-item") response)

    end
end

module Moderate = struct

  let () = CClient.User.register CClient.is_contact UrlWall.moderate
    begin fun ctx request response ->
      
      let fail = return (O.Action.javascript Js.panic response) in

      let! feed = req_or fail (request # args 0) in
      let feed = IFeed.of_string feed in 

      let! item = req_or fail (request # args 1) in
      let item = IItem.of_string item in 

      let! feed = ohm_req_or fail (MFeed.try_get ctx feed) in
      let! feed = ohm_req_or fail (MFeed.Can.admin feed) in
     
      let! () = ohm (MItem.Remove.moderate item (`feed (MFeed.Get.id feed))) in
      return (O.Action.javascript (Js.removeParent ".wall-item") response)

    end
end

(* Grabbing all replies *)

let () = CClient.User.register CClient.is_contact (UrlWall.more_replies ()) 
  begin fun ctx request response ->

    let i18n = ctx # i18n in
    let fail = O.Action.json (Js.More.return (View.str "")) response in

    let! item_id = req_or (return fail) (request # args 0) in
    let  item_id = IItem.of_string item_id in 

    let! item_p  = req_or (return fail) (request # args 1) in
      
    let! item     = 
      req_or (return fail)
	(IItem.Deduce.from_read_token (IIsIn.user (ctx # myself)) item_id item_p) 
    in

    let! replies = ohm $ MComment.all item in
        
    replies
    |> Run.list_filter (fun (cid,_) -> CItem.reply ctx cid) 
    |> Run.map (List.map (fun data -> VWall.Reply.render data i18n)) 
    |> Run.map View.concat
    |> Run.map (fun view -> O.Action.json (Js.More.return view) response)

end


