(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

let () = CCore.register (UrlCore.message ()) begin fun i18n request response ->

  let generic_fail = Action.redirect (UrlLogin.index # build) response in 

  let! user  = req_or (return generic_fail) (request # args 1) in
  let  user  = IUser.of_string user in

  let! mid   = req_or (return generic_fail) (request # args 0) in
  let  mid   = IMessage.of_string mid in

  let! proof = req_or (return generic_fail) (request # args 2) in

  let! iid = ohm_req_or (return generic_fail) $ MMessage.get_instance mid in
  let! instance = ohm_req_or (return generic_fail) $ MInstance.get iid in

  let redirect = Action.redirect (UrlMessage.build instance mid) response in
  
  let user' = BatOption.bind CSession.get_login_cookie (request # cookie CSession.name) in
  
  if Some user <> BatOption.map IUser.Deduce.unsafe_is_anyone user' then
    
    match IUser.Deduce.from_login_token proof user with 
      | None -> 
	
	return $ CSession.with_logout_cookie redirect
	  
      | Some user ->
	
	let login = IUser.Deduce.current_can_login user in 

	let! _ = ohm $ MNews.FromLogin.create 
	  (`Notification (iid,`message,IUser.decay login))
	in

	return $ CSession.with_login_cookie login false redirect 
	  
  else
    
    return redirect


end

module Create = struct

  module Fields = FMessage.Create.Fields
  module Form   = FMessage.Create.Form

  let create ~ctx = 
    O.Box.reaction "create" begin fun self input _ response ->
    
      let title = ref "" in
      
      let form = Form.readpost (input # post)
        |> Form.mandatory `Title Fmt.String.fmt title (ctx # i18n, `label "messages.create-form.title.required")
      in
      
      if Form.not_valid form then
	return (Action.json (Form.response form) response)
      else
	
	let! self = ohm $ ctx # self in
	
	let! mid = ohm $ MMessage.create
	  ~instance:(IInstance.decay (IIsIn.instance ctx # myself))
	  ~who:self
	  ~title:(!title)
	  ~invited:[]
	in
		
	let js = JsCode.seq [
	  Js.Dialog.close ;
	  Js.redirect (UrlMessage.build (ctx # instance) mid)
	] in
	
	return  $Action.javascript js response
	  
    end
      
  let prepare ~ctx ~create =
    O.Box.reaction "prepare" begin fun self input url response ->
      
      let i18n = ctx # i18n in
      
      let url = input # reaction_url create in 

      let title = I18n.translate i18n (`label "messages.create.title") in    
      let body  = 
	VMessage.create ~url ~init:Form.empty ~i18n 
      in    
      
      let dialog = Js.Dialog.create body title in 
      
      return (Action.javascript dialog response)
    end

  let reaction ~ctx callback = 
    let! create = create ~ctx in
    let! prepare = prepare ~ctx ~create in
    callback prepare

end

let home_box ~ctx = 

  let has_token = IIsIn.Deduce.is_token (ctx # myself) in
  let tokctx = BatOption.map (fun isin -> CContext.evolve_full isin ctx) has_token in 

  let! prepare = optional tokctx (fun ctx -> Create.reaction ~ctx) in

  O.Box.leaf
    begin fun input url ->

      let i18n = ctx # i18n in
      
      let user   = ctx # myself
	|> IIsIn.user 
	|> IUser.Deduce.current_is_anyone
	(* For messages, act as self (dangerous!) *)
	|> IUser.Assert.is_self
      in

      let! unread = ohm begin 
	let! count = ohm $ MMessage.count user in
	return $ (fun i -> try List.assoc (IInstance.decay i) count with Not_found -> 0)
      end in      

      let segs = Box.Seg.(root ++ CSegs.root_pages) in

      let iid = IInstance.decay (IIsIn.instance ctx # myself) in

      let! asso_img = ohm (ctx # picture_small (ctx # instance # pic))in
      
      let score = function `Admin -> 0 | `Token -> 1 | `Contact -> 2 in
      
      let! assos  = ohm begin 
	user
	|> IUser.Deduce.self_can_view_inst
	|> MAvatar.user_instances
	|> Run.bind (Run.list_filter begin fun (s,i) ->
	  let! instance = ohm_req_or (return None) $ MInstance.get i in
	  if iid = IInstance.decay i then return None else 
	    ctx # picture_small (instance # pic) |> Run.map begin fun pic -> 		
	      Some (object
		method status   = CContext.status instance s
		method sort     = score s, fold_all (instance # name) 
		method name     = instance # name
		method url      = UrlR.build instance segs ((),`Messages)
		method pic      = pic
		method unread   = unread i
	      end)
	    end	
	end)
	|> Run.map (List.sort (fun a b -> compare (a # sort) (b # sort)))
	|> Run.map (fun l -> (l :> VMessage.asso_item list))
      end in	
	
      let! messages = ohm begin 
	let limit = 100 in
	
	let! items = ohm $ MMessage.get_by_instance user iid limit in
	
	Run.list_map begin fun item ->
	  let avatar, is_me = 
	    if Some (item # last_by) = BatOption.map IAvatar.decay ctx # self_if_exists then 
	      match item # prev_by with 
		| Some other -> other, false
		| None -> item # last_by, true
	    else 
	      item # last_by, false
	  in
	  
	  let! details = ohm $ MAvatar.details avatar in
	  let! picture = ohm $ ctx # picture_small (details # picture) in

	  return ( object
	    method picture = picture
	    method time    = item # last
	    method read    = item # read
	    method title   = item # title
	    method url     = UrlMessage.build (ctx # instance) (item # id)
	    method people  = 
	      let name = CName.get i18n details in 
	      if is_me || item # people = 1 then
		I18n.translate i18n (`label "messages.people.1")
	      else 
		let message, data = 
		  if item # people = 2 then 
		    "messages.people.2", [View.esc name]
		  else if item # people = 3 then 
		    "messages.people.3", [View.esc name]
		  else 
		    "messages.people.n", [View.esc name;
					  View.esc (string_of_int (item # people - 2))]
		in 
		View.write_to_string (I18n.get_param i18n message data) 
	  end )	
	end items     
      end in
      
      let create = BatOption.map (input # reaction_url) prepare in
      
      let asso_url = UrlR.home # build (ctx # instance) in
      
      return $ VMessage.home
	~asso_img ~asso_url ~messages ~create ~assos ~instance:(ctx # instance) 
	~i18n:(ctx # i18n)

    end
    
module Participants = struct
  let listid = Id.of_string "invited"
end

module Invite = struct

  module Fields = FMember.Select.Fields
  module Form   = FMember.Select.Form

  module CMember = Fmt.Make(struct
    type json t = Id.t * string
  end)
    
  let reaction ~ctx = 
    O.Box.reaction "invite" begin fun self input (_,optmid) response ->
      
      let panic = CCore.js_fail Js.panic response in 
      let i18n  = ctx # i18n in 
      
      let! mid = req_or panic optmid in
      
      let member = ref (Id.of_string "", "") in
      let form = Form.readpost (input # post) 
        |> Form.mandatory `Pick CMember.fmt member (i18n, `label "")
      in
      
      if Form.not_valid form then CCore.json_fail (Form.response form) response 
      else begin
	
	let avatar = IAvatar.of_id (fst !member) in
	
	let! details = ohm (MAvatar.details avatar) in
	let! picture = ohm (ctx # picture_small (details #  picture)) in
	
	let item = VMessage.participant
	  ~picture
	  ~name:(CName.get i18n details)
	  ~status:(ctx # status (match details # status with Some s -> s | None -> `Contact))
	  ~id:avatar
	  ~url:(UrlProfile.page ctx avatar)
	  ~i18n 
	in

	let! () = ohm (MMessage.invite ~ctx ~invited:[avatar] mid) in
	
	return (
	  Action.javascript (
	    Js.appendUniqueList Participants.listid item (IAvatar.to_id avatar)
	  ) response
	)
      end
    end    
    
end
      
let message_box ~(ctx:'a CContext.full) =   

  let i18n = ctx # i18n in 
  let url_msg, url_asso = 
    let segs =   
      let (++) = Box.Seg.(++) in   
      Box.Seg.root ++ CSegs.root_pages
    in
    UrlR.build (ctx # instance) segs ((),`Messages),
    UrlR.build (ctx # instance) segs ((),`Home)
  in

  let tokctx = match IIsIn.Deduce.is_token (ctx # myself) with
    | Some has_token -> Some (CContext.evolve_full has_token ctx)
    | None           -> None
  in

  let content = "c" in  
  
  let default = 
    return (
      O.Box.node 
	begin fun input (prefix,optmid) -> 
	  return [], return (VMessage.missing ~url_msg ~i18n) 
	end
    )
  in

  (* This function first fetches all necessary data for rendering. After it has fetched everything
     and determined that nothing is missing, it returns a node box that uses all that data. *)
   
  O.Box.decide 
    begin fun _ (prefix,optmid) -> 
      
      let! mid = req_or default optmid in

      let user   = ctx # myself
        |> IIsIn.user 
	|> IUser.Deduce.current_is_anyone
	(* For messages, act as self (dangerous!) *)
	|> IUser.Assert.is_self
      in	      

      (* Mark the message as read before doing anything. *)
      let! () = ohm (MMessage.mark_as_read user mid) in
	
      (* Extract available participants *)
      let! participants = ohm begin
	MMessage.get_participants ctx mid 
	|> Run.map (function `Forbidden -> None | `List participants -> Some participants)
      end in
      
      let! participants = req_or default participants in

      (* Extract available groups. *)
      let! groups = ohm begin 
	MMessage.get_groups ctx mid
	|> Run.map (function `Forbidden -> None | `List groups -> Some groups)
      end in

      let! groups = req_or default groups in

      (* Extract the message title *)

      let! title = ohm begin 
	MMessage.get_title ctx mid
	|> Run.map (function `Forbidden | `None -> None | `Some title -> Some title)
      end in

      let! title = req_or default title in

      (* Grab the wall for this message *)
      
      let! wall = ohm (MMessage.find_feed ctx mid) in

      (* We have everything we need, so we can now build the actual node box. *)

      return (

	let! invite_reaction       = optional tokctx (fun ctx -> Invite.reaction ~ctx) in

	O.Box.node 
	  begin fun input (prefix,optmid) -> 	    

	    (* Constructing the sub-boxes is easy : there's only one *)
	    let sub_boxes = 
	      let config = object
		method chat _ = None
		method react  = false
	      end in 
	      return [content, CWall.full_nested_box ~ctx ~wall ~config]
	    in
            
	    (* On the other hand, we need to build the inner view... *) 
	    let content = 
	      
	      let name_asso = ctx # instance # name in 
	      let content = (input # name, content) in
	      
	      (* Grab the invited people and prepare them for rendering. *)
	      let!
		people = ohm begin 
		  participants 
		  |> Run.list_map begin fun aid -> 
		    let! details = ohm (MAvatar.details aid) in
  	            let! picture = ohm (ctx # picture_small (details # picture)) in
		    return ( object
		      method id      = aid 
		      method name    = CName.get i18n details 
		      method picture = picture
		      method status  = ctx # status 
			(match details # status with Some s -> s | None -> `Contact)
		      method url     = UrlProfile.page ctx aid
		    end ) 
		  end
		end in
	      
	      (* Grab invited entities and prepare them for rendering. *)
	      let! 
		entities = ohm begin 	    
		  groups |> Run.list_filter begin fun (gid,access) ->
		    let none = return None in
		    let! group_opt   = ohm (MGroup.naked_get gid) in
	            let! group       = req_or none group_opt in
		    let! entity_id   = req_or none (MGroup.Get.entity group) in			      
		    let! entity_opt  = ohm (MEntity.try_get ctx entity_id) in
		    let! entity      = req_or none entity_opt in
		    let! entity_view = ohm (MEntity.Can.view entity) in
		     
		    return (Some (
		      IGroup.to_id gid,
		      access,
		      MEntity.Get.kind entity,
		      BatOption.map MEntity.Get.name entity_view
		    ))
		  end
		end in	     

	      (* Build the appropriate buttons for inviting people, if user can see them *)

	      let! view_directory = ohm (MInstanceAccess.can_view_directory ctx) in

	      let add = 
		match view_directory, invite_reaction with 
		  | Some iid, Some reaction -> 
		    let picker = 
		      CMember.contact_picker (ctx # instance) iid (ctx # myself) (ctx # i18n) in
		    Some (object
		      method url    = input # reaction_url reaction
		      method init   = FMember.Select.Form.empty
		      method config = ( object method picker = picker end)
		    end)
		  | _ -> None
	      in

	      (* Return the constructed view *)
	      return (
		VMessage.single 
		  ~people_id:Participants.listid 
		  ~entities
		  ~add ~people ~url_asso ~url_msg ~name_asso ~title ~content 
		  ~i18n
	      )		
	    in

	    sub_boxes, content
	  end
      )    

    end
  |> O.Box.parse CSegs.message_id
