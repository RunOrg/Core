(* © 2012 RunOrg *)

open Ohm
open O
open Ohm.Universal
open BatPervasives

(* The form buttons ------------------------------------------------------------------------- *)

let buttons status quit fields = 

  let no_js   = JsCode.seq [ Js.runFromServer quit ] in
  let no      = match status with 
    | `Unpaid   
    | `Member
    | `Pending   -> Some (`label "membership.button.leave",   no_js)
    | `Invited   -> Some (`label "membership.button.decline", no_js)
    | `Declined
    | `NotMember -> None
  in
  
  let yes = match status with 
    | `Unpaid    -> Some (`label "membership.button.pay")
    | `Declined 
    | `Invited   -> Some (`label "membership.button.accept")
    | `NotMember -> Some (`label "membership.button.join")
    | `Pending
    | `Member    -> if fields = [] then None else Some (`label "save")
  in

  let status = VLabel.of_status status in 

  VJoin.Self.Form.render (VJoin.Self.render_buttons ?yes ?no status) 

(* Data access ----------------------------------------------------------------------------- *)

type fields_by_group = 
    (IGroup.t * (string * MJoinFields.Field.t) list) list

type data_by_group   =
    (IGroup.t * (string * Json_type.t) list) list

let get_fields_and_joins gid aid = 
    let! fields_by_group = ohm $ MGroup.Fields.complete gid in
    let  groups = List.map fst fields_by_group in
    let data_of_group gid = 
      let! id = ohm $ MMembership.as_user gid aid in 
      let! data = ohm $ MMembership.Data.get id in 
      return (gid,data)
    in
    let! data_by_group = ohm $ Run.list_map data_of_group groups in
    return (fields_by_group, data_by_group)
  
(* Construct the form ----------------------------------------------------------------------- *)

let get_from_data gid name fields = 
  try List.assoc name (List.assoc gid fields) with _ -> Json_type.Null

let add_to_data gid name value data = 
  let by_gid = BatOption.default [] $ ListAssoc.try_get data gid in
  ListAssoc.replace gid (ListAssoc.replace name value by_gid) data

let form_field field = 
  let required = List.mem `required (field # valid) in
  let label    = field # label in 

  let string_of_json i18n = function Json_type.String s -> s | _ -> "" in
  let string_opt_of_json i18n = function Json_type.String s -> Some s | _ -> None in
  let json_of_string i18n field = function 
    | None   -> Ok (Json_type.Null)
    | Some s -> Ok (Json_type.String s)
  in

  let bool_of_list i18n field list = Ok (Json_type.Bool (list <> [])) in
  let list_of_bool i18n = function 
    | Json_type.Bool true -> [1] 
    | _                   -> []
  in

  let choice labels multiple = 
    let source = 
      labels 
      |> BatList.mapi (fun i l -> i, l)
      |> BatList.filter_map 
	  (fun (i,l) -> if l = `text "" || l = `label "" then None else Some (i,l))
      |> List.map (fun (i,l) -> i, (fun i18n -> I18n.get i18n l))
    in
    let json_of_list i18n field list = Ok (Json_type.Build.list Json_type.Build.int list) in
    let list_of_json i18n = function
      | Json_type.Array l -> 
	BatList.filter_map (function 
	  | Json_type.Int i -> Some i 
	  | Json_type.Array (Json_type.Int i :: _) -> Some i
	  | _ -> None) l 
      | _                 -> []
    in
    VQuickForm.choice ~label ~format:Fmt.Int.fmt ~source ~multiple list_of_json json_of_list 
  in

  match field # edit with
    | `textarea -> VQuickForm.textarea  ~label ~required string_of_json json_of_string
    | `date     -> VQuickForm.date      ~label ~required string_opt_of_json json_of_string
    | `longtext -> VQuickForm.longinput ~label ~required string_of_json json_of_string
    | `checkbox -> VQuickForm.choice    ~label:(`text "") ~format:Fmt.Int.fmt ~source:[
      1 , (fun i18n -> I18n.get i18n label)
    ] ~multiple:true list_of_bool bool_of_list 
    | `pickOne  choices -> choice choices false
    | `pickMany choices -> choice choices true

let form status quit (fields : fields_by_group) = 
  let fields = List.concat $
    List.map (fun (gid,l) -> List.map (fun (n,f) -> gid,n,f) l) fields
  in
  let with_fields = List.fold_left begin fun form (gid,name,field) -> 
    let field = Joy.seed_map (get_from_data gid name) $ form_field field in 
    Joy.append (add_to_data gid name) form field
  end (Joy.begin_object []) (List.rev fields) in
  Joy.wrap Joy.here (buttons status quit fields) with_fields

(* Display the form in a modal dialog ------------------------------------------------------- *)

let () = CClient.User.register CClient.is_anyone UrlJoin.self_edit
  begin fun ctx request response -> 

    let fail = return response in 

    let! eid = req_or fail (request # args 0) in
    let  eid = IEntity.of_string eid in 

    let! entity = ohm_req_or fail $ MEntity.try_get ctx eid in 
    let! entity = ohm_req_or fail $ MEntity.Can.view entity in
    let  gid    = MEntity.Get.group entity in 
    
    let! self         = ohm $ ctx # self in
    let! fields, data = ohm $ get_fields_and_joins gid self in
    let! mid = ohm $ MMembership.as_user gid self in

    let! membership = ohm $ MMembership.get mid in     
    let  status =
      BatOption.map (fun m -> m.MMembership.status) membership 
      |> BatOption.default `NotMember
    in 
     
    let  source = Joy.from_seed data in
    let  quit   = UrlJoin.self_quit # build (ctx # instance) eid in    
    let  form   = Joy.create
      ~template:(form status quit fields) 
      ~i18n:(ctx # i18n)
      ~source 
    in

    let name    = CName.of_entity entity in 

    let url     = UrlJoin.self_edit_post # build (ctx # instance) eid in 
    let body    = Joy.render form url in
    let title   = I18n.translate (ctx # i18n) name in 
    let options = [ "width",     Json_type.Int 734 ;
		    "minHeight", Json_type.Int 45 ;
		    "position",  Json_type.Array 
		      [ Json_type.String "center" ; Json_type.Int 40 ]
		  ]
    in

    return $ Action.javascript (Js.Dialog.create ~options body title) response

  end

(* Process the returned form --------------------------------------------------------------- *)

let () = CClient.User.register CClient.is_anyone UrlJoin.self_edit_post
  begin fun ctx request response -> 

    let fail = return response in 

    let! eid = req_or fail (request # args 0) in
    let  eid = IEntity.of_string eid in 

    let! entity = ohm_req_or fail $ MEntity.try_get ctx eid in 
    let! entity = ohm_req_or fail $ MEntity.Can.view entity in
    let  gid    = MEntity.Get.group entity in 
    
    let! self         = ohm $ ctx # self in
    let! fields, data = ohm $ get_fields_and_joins gid self in
    let! mid          = ohm $ MMembership.as_user gid self in
    let! membership   = ohm $ MMembership.get mid in     

    let  status =
      BatOption.map (fun m -> m.MMembership.status) membership 
      |> BatOption.default `NotMember
    in 

    let  source = Joy.from_post_json (request # json) in
    let  quit   = UrlJoin.self_quit # build (ctx # instance) eid in 
    let  form   = Joy.create
      ~template:(form status quit fields) 
      ~i18n:(ctx # i18n)
      ~source 
    in

    match Joy.result form with
      | Bad errors ->
	
	let json = Joy.response (Joy.set_errors errors form) in
	return $ Action.json json response
	  
      | Ok result ->
	
	(* If necessary, confirm the join *)
	
	let should_confirm = match membership with None -> true | Some m -> 
	  match m.MMembership.status with `NotMember | `Invited | `Declined -> true | _ -> 
	    match m.MMembership.user with None -> true | Some (any,_,aid) -> 
	      if any = false then true else 
		if aid = IAvatar.decay self then false else true
	in
	
	let! () = ohm begin 
	  if should_confirm then 
	    MMembership.user gid self true
	  else
	    return ()
	end in
	
	(* Individually set all form data for the various fields. *)
	
	let update = MUpdateInfo.info ~who:(`user (Id.gen(),IAvatar.decay self)) in
	
	let set_group_data (gid,fields) =
	  
	  let existing = BatOption.default [] $ ListAssoc.try_get data   gid in
	  let saved    = BatOption.default [] $ ListAssoc.try_get result gid in 
	  
	  let diff  = BatList.filter_map begin fun (name,_) -> 
	    let current = BatOption.default Json_type.Null $ ListAssoc.try_get existing name in 
	    let saved   = BatOption.default Json_type.Null $ ListAssoc.try_get saved    name in 
	    if saved <> current then Some (name, saved) else None
	  end fields in 
	  
	  MMembership.Data.self_update gid self update diff       
	in
	
	let! _ = ohm $ Run.list_iter set_group_data fields in
	
	let code = 
	  JsCode.seq [ 
	    Js.message (I18n.get (ctx # i18n) (`label "changes.saved")) ;
	    Js.Dialog.close ;
	    JsBase.boxRefresh 0.0
	  ]	  
	in
	
	return $ Action.javascript code response
	  
  end

(* Decline invitation or leave group -------------------------------------------------------- *)

let () = CClient.User.register CClient.is_anyone UrlJoin.self_quit
  begin fun ctx request response -> 

    let fail = return response in 

    let! eid = req_or fail (request # args 0) in
    let  eid = IEntity.of_string eid in 

    let! entity = ohm_req_or fail $ MEntity.try_get ctx eid in 
    let! entity = ohm_req_or fail $ MEntity.Can.view entity in
    let  gid    = MEntity.Get.group entity in 
    
    let! self         = ohm $ ctx # self in
    let! mid          = ohm $ MMembership.as_user gid self in
    let! membership   = ohm $ MMembership.get mid in     

    (* If necessary, confirm the join *)
    
    let should_quit = match membership with None -> true | Some m ->
      match m.MMembership.user with None -> true | Some (any,_,aid) -> 
	if any = true then true else 
	  if aid = IAvatar.decay self then false else true
    in
	
    let! () = ohm begin 
      if should_quit then 
	MMembership.user gid self false
      else
	return ()
    end in
	
    let code = 
      JsCode.seq [ 
	Js.message (I18n.get (ctx # i18n) (`label "changes.saved")) ;
	Js.Dialog.close ;
	JsBase.boxRefresh 0.0
      ]	  
    in
    
    return $ Action.javascript code response
      
  end

