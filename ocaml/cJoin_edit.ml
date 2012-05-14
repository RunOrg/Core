(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let empty i18n = identity

let render_text_field = function
  | Json_type.String s -> (fun i18n vctx -> View.str (VText.format s) vctx)
  | _ -> empty

let render_date_field = function
  | Json_type.String s -> begin fun i18n vctx -> 
    match MFmt.format_date (I18n.language i18n) s with 
      | None   -> vctx
      | Some d -> View.esc d vctx
  end
  | _ -> empty

let render_checkbox = function
  | Json_type.Bool b -> 
    begin fun i18n vctx ->
      let label = if b then `label "yes" else `label "no" in
      View.esc (I18n.translate i18n label) vctx
    end
  | _ -> empty

let render_picker list json = 
  let int_choices = match json with 
    | Json_type.Int i -> [i]
    | Json_type.Array l -> BatList.filter_map (function
	| Json_type.Int i -> Some i
	| _               -> None
    ) l 
    | _ -> []
  in
  let i18n_choices = BatList.filter_map 
    (fun i -> try Some (List.nth list i) with _ -> None) int_choices
  in
  begin fun i18n vctx -> 
    let text_choices = List.map (I18n.translate i18n) i18n_choices in 
    View.esc (String.concat ", " text_choices) vctx
  end

let render_field data field = 

  let json = 
    try List.assoc (field # name) data 
    with Not_found -> Json_type.Null
  in

  let value = match field # edit with 
    | `textarea 
    | `longtext   -> render_text_field json 
    | `date       -> render_date_field json
    | `checkbox   -> render_checkbox   json
    | `pickOne  l
    | `pickMany l -> render_picker l   json  
  in

  field # label, value 

let argname = "a"

let get_arg = function
  | Some "true"  -> Some true
  | Some "false" -> Some false
  | _            -> None

let button bctx arg reaction = 
  let arg = match arg with 
    | None       -> "null"
    | Some true  -> "true"
    | Some false -> "false"
  in
  Js.runFromServer 
    ~disable:true
    ~args:(Json_type.Object [ argname , Json_type.String arg ])
    (bctx # reaction_url reaction)

let edit_invite ~ctx ~group aid = 

  O.Box.reaction "invite" begin fun _ bctx _ response -> 

    let! self = ohm $ ctx # self in
    let! ()   = ohm $ MMembership.admin 
      ~from:self (MGroup.Get.id group) aid [ `Invite ]
    in

    return $ O.Action.javascript (JsBase.boxRefresh 0.0) response

  end

let edit_member ~ctx ~group aid = 

  let show_edit_member self bctx response = 

    let html = VJoin.Manage.Member_Write.render (object
      method yes = button bctx (Some true)  self
      method no  = button bctx (Some false) self
    end) (ctx # i18n) in

    let js = Js.replaceOtherWith ".member-status" html in

    return $ O.Action.javascript js response 
    
  in

  let apply_edit_member bctx b response =
    let! self = ohm $ ctx # self in
    let! ()   = ohm $ MMembership.admin 
      ~from:self (MGroup.Get.id group) aid [ `Default b ]
    in
    return $ O.Action.javascript (JsBase.boxRefresh 0.0) response
  in

  O.Box.reaction "edit-member" begin fun self bctx _ response -> 
    let arg = get_arg (bctx # post argname) in
    match arg with 
      | None   -> show_edit_member  self bctx   response
      | Some b -> apply_edit_member      bctx b response
  end

let edit_admin ~ctx ~group aid = 

  let show_edit_admin self bctx response = 

    let html = VJoin.Manage.Validation_Write.render (object
      method yes = button bctx (Some true)  self
      method no  = button bctx (Some false) self
    end) (ctx # i18n) in

    let js = Js.replaceOtherWith ".validation-status" html in

    return $ O.Action.javascript js response 
    
  in

  let apply_edit_admin bctx b response =
    let! self = ohm $ ctx # self in
    let! ()   = ohm $ MMembership.admin 
      ~from:self (MGroup.Get.id group) aid [ `Accept b ]
    in
    return $ O.Action.javascript (JsBase.boxRefresh 0.0) response
  in

  O.Box.reaction "edit-admin" begin fun self bctx _ response -> 
    let arg = get_arg (bctx # post argname) in
    match arg with 
      | None   -> show_edit_admin  self bctx   response
      | Some b -> apply_edit_admin      bctx b response
  end

let box ~ctx ~entity ~group aid = 

  (* Define all reactions *)
  let! edit_member = edit_member ~ctx ~group aid in 
  let! edit_admin  = edit_admin  ~ctx ~group aid in 
  let! edit_invite = edit_invite ~ctx ~group aid in 

  O.Box.leaf begin fun bctx (prefix,_) -> 
    let  gid     = MGroup.Get.id group in 
    let! mid     = ohm $ MMembership.as_admin gid aid in 
    let! current = ohm $ MMembership.get mid in 
    let! data    = ohm $ MMembership.Data.get mid in 
    let  fields  = MGroup.Fields.get group in 

    let  status  = match current with 
      | Some m -> m.MMembership.status
      | None   -> `NotMember
    in

    let! details = ohm $ CAvatar.extract_one (ctx # i18n) ctx aid in 
    let  back_url = 
      UrlR.build (ctx # instance) 
	O.Box.Seg.(UrlEntity.segments ++ UrlSegs.entity_tabs) (prefix)
    in

    let data = if fields = [] then None else 
	let items = List.map (render_field data) fields in 
	Some (object
	  method items = items 
	  method edit  = JsCode.seq []
	end)
    in

    let mbr_invited, mbr_admin, mbr_user = match current with 
      | None   -> None, None, None
      | Some c -> MMembership.( c.invited, c.admin, c.user )
    in

    let user_responded =
      match mbr_user with 
	| Some (_,_,aid') -> aid = aid'
	| None            -> false
    in 

    let action_of = function 
      | None           -> return None
      | Some (_,t,aid) -> let! details = ohm $ CAvatar.extract_one (ctx # i18n) ctx aid in 
			  return $ Some (object
			    method time    = t
			    method name    = details # name
			    method picture = details # picture
			    method profile = details # url
			  end)
    in
 
    let! invite = ohm begin 
      let show_invite = match mbr_invited, mbr_user with 
	| Some (_,_,inviter) , _    -> inviter <> aid
	| _                  , None -> true 
	| None               , _    -> not user_responded
      in
      
      if not show_invite then return None else 
	let! action = ohm $ action_of mbr_invited in 
	return $ Some (object
	  method action = action 
	  method invite = if user_responded then None else Some (button bctx None edit_invite)
	end)
    end in 

    let! member = ohm begin 
      let! action   = ohm $ action_of mbr_user in 
      let  edit     = 
	if user_responded then None else 
	  Some (button bctx None edit_member) 
      in
      let  action = match mbr_user with 
	| Some (what,_,_) -> BatOption.map (fun a -> what, a) action
	| None            -> None
      in

      return (object
	method action = action
	method edit   = edit
	method yes    = button bctx (Some true)  edit_member
	method no     = button bctx (Some false) edit_member
       end)
    end in 

    let! admin = ohm begin 
      let! action = ohm $ action_of mbr_admin in 
      let  status = match mbr_admin with 
	| Some (what,_,_) -> what 
	| None            -> let  config = MEntity.Get.config entity in 
			     let! group  = req_or true (config # group) in
			     match group # validation with 
			       | `manual -> false
			       | `none   -> true
      in
      return (object
	method action = action
	method status = status
	method edit   = button bctx  None        edit_admin
	method yes    = button bctx (Some true)  edit_admin
	method no     = button bctx (Some false) edit_admin
      end)
    end in
    
    let page = object
      method back    = back_url 
      method picture = details # picture 
      method name    = details # name
      method status  = details # status
      method profile = details # url
      method join    = status
      method invite  = invite
      method data    = data
      method member  = member
      method admin   = admin
    end in 

    return $ VJoin.Manage.Page.render page (ctx # i18n)

  end

