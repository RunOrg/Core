(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let do_join self group =   
  let! admin = ohm $ MGroup.Can.write group in   
  match admin with
    | None -> MMembership.user (MGroup.Get.id group) self true 
    | Some group -> MMembership.admin ~from:self (MGroup.Get.id group) self [ `Accept true ; `Default true ]

let save_data self result = 

  let  result = MJoinFields.Flat.dispatch result in 
  
  let  info = MUpdateInfo.info ~who:(`user (Id.gen (), IAvatar.decay self)) in

  let! ()   = ohm (Run.list_iter begin fun (gid, data) ->
    MMembership.Data.self_update gid self info data
  end result # groups) in

  match MProfile.Data.apply (result # profile) with 
    | None -> return ()
    | Some f -> let! pid = ohm $ MAvatar.my_profile self in 
		MProfile.update pid f
 

let template button fields = 
  List.fold_left (fun acc field -> 

    let name, edit = match field with 
      | `Group   f -> `Group   (f # name), f # edit
      | `Profile f -> `Profile (f # name), f # edit 
    in

    let label = 
      TextOrAdlib.to_string (match field with 
	| `Group   f -> f # label
	| `Profile f -> f # label)
    in 

    let json self = match field with 
      | `Group f -> let  gid, name = f # name in 
		    let! mid  = ohm $ MMembership.as_user gid self in 
		    let! data = ohm $ MMembership.Data.get mid in 
		    return (try List.assoc name data with Not_found -> Json.Null)
      | `Profile f -> let  what = f # name in 
		      let! pid  = ohm $ MAvatar.my_profile self in 
		      let! _, data = ohm_req_or (return Json.Null) $ MProfile.data pid in
		      return (MProfile.Data.field data what) 
    in

    acc |> OhmForm.append (fun json result -> return $ (name,result) :: json)
	begin match edit with
	  | `Checkbox ->
	    (VEliteForm.checkboxes ~label
	       ~format:Fmt.Unit.fmt
	       ~source:[ (), return ignore ]
	       (fun self -> let! json = ohm (json self) in 
			    return (try if Json.to_bool json then [()] else [] with _ -> []))
	       (fun field data -> return $ Ok (Json.Bool (data <> []))))
	  | `Date ->
	    (VEliteForm.date ~label
	       (fun self -> let! json = ohm (json self) in
			    return (try Json.to_string json with _ -> ""))
	       (fun field data -> return $ Ok (Json.String data)))
	  | `LongText -> 
	    (VEliteForm.text ~label
	       (fun self -> let! json = ohm (json self) in
			    return (try Json.to_string json with _ -> ""))
	       (fun field data -> return $ Ok (Json.String data))) 
	  | `PickOne list -> 
	    (VEliteForm.radio ~label
	       ~format:Fmt.Int.fmt
	       ~source:(BatList.mapi (fun i label -> i, TextOrAdlib.to_html label) list)
	       (fun self -> let! json = ohm (json self) in
			    return (try Some (Json.to_int json) with _ -> None))
	       (fun field data -> return $ Ok (Json.of_opt Json.of_int data)))
	  | `PickMany list ->
	    (VEliteForm.checkboxes ~label
	       ~format:Fmt.Int.fmt
	       ~source:(BatList.mapi (fun i label -> i, TextOrAdlib.to_html label) list)
	       (fun self -> let! json = ohm (json self) in
			    return (try Json.to_list Json.to_int json with _ -> []))
	       (fun field data -> return $ Ok (Json.of_list Json.of_int data)))
	  | `Textarea ->
	    (VEliteForm.textarea ~label
	       (fun self -> let! json = ohm (json self) in
			    return (try Json.to_string json with _ -> ""))
	       (fun field data -> return $ Ok (Json.String data))) 
	end 
  ) (OhmForm.begin_object []) fields

  |> VEliteForm.with_ok_button ~ok:(AdLib.get button)

let css_invited = "-invited"
let css_none    = "-none"
let css_joined  = "-joined"

let label ~gender ~kind ~status = 
  match status with 
    | `NotMember 
    | `Declined -> begin
      match kind with 
	| `Event -> `Join_Self_Event_NotMember gender
	| `Forum -> `Join_Self_Forum_NotMember gender
	| _      -> `Join_Self_Group_NotMember gender      
    end
    | `Member -> begin
      match kind with 
	| `Event -> `Join_Self_Event_Member gender
	| `Forum -> `Join_Self_Forum_Member gender
	| _      -> `Join_Self_Group_Member gender      
    end
    | `Invited -> `Join_Self_Event_Invited gender
    | `Pending -> `Join_Self_Pending gender
    | `Unpaid  -> `EMPTY

let css = function
  | `NotMember -> css_none
  | `Member    -> css_joined
  | `Invited   -> css_invited
  | `Pending   -> css_joined
  | `Unpaid    -> css_none
  | `Declined  -> css_none

let render jid key ~gender ~kind ~status ~fields = 

  let action what = object
    method url  = Action.url UrlClient.Join.ajax key jid  
    method data = Json.Bool what
  end in

  let buttons = match status with 
    | `NotMember -> [(object
      method green = true
      method label = AdLib.write (if fields then `Join_Self_JoinEdit else `Join_Self_Join)
      method action = action true
    end)]
    | `Member ->
      let cancel = object 
	method green = false
	method label = AdLib.write `Join_Self_Cancel
	method action = action false
      end in 
      if fields then 
	[ cancel ;
	  (object
	    method green = false
	    method label = AdLib.write `Join_Self_Edit
	    method action = action true
	   end)
	]
      else 
	[ cancel ]
    | `Invited -> [
	(object
	  method green = false
	  method label = AdLib.write `Join_Self_Decline
	  method action = action false
	 end) ;
	(object
	  method green = false
	  method label = AdLib.write (if fields then `Join_Self_AcceptEdit else `Join_Self_Accept)
	  method action = action true
	 end) ;
      ]
    | `Pending -> [
	(object
	  method green = false
	  method label = AdLib.write `Join_Self_Cancel
	  method action = action false
	 end)
      ]
    | `Unpaid -> []
    | `Declined -> [(object
      method green = true
      method label = AdLib.write (if fields then `Join_Self_JoinEdit else `Join_Self_Join)
      method action = action true
    end)]    
  in

  Asset_Join_Self.render (object
    method status = css status
    method text = AdLib.write (label ~kind ~gender ~status)
    method buttons = buttons
  end)

let () = UrlClient.Join.def_post $ CClient.action begin fun access req res -> 

  (* Check that entity is available for joining *)

  let panic = return $ Action.javascript (Js.reload ()) res in 

  let  jid = req # args in 
  
  let! gid = ohm_req_or panic begin 
    match jid with 
      | `Entity eid -> let! entity = ohm_req_or (return None) $ MEntity.try_get access eid in
		       let! entity = ohm_req_or (return None) $ MEntity.Can.view entity in
		       return $ Some (MEntity.Get.group entity) 
      | `Event eid -> let! event = ohm_req_or (return None) $ MEvent.get ~access eid in
		      let! event = ohm_req_or (return None) $ MEvent.Can.view event in 
		      if MEvent.Get.draft event then return None else
			return $ Some (MEvent.Get.group event) 
  end in 

  let! group  = ohm_req_or panic $ MGroup.try_get access gid in
  let! fields = ohm $ MGroup.Fields.flatten gid in 

  (* Extract form data *)

  let! json = req_or panic $ Action.Convenience.get_json req in

  let  template = template `Join_Self_Save fields in

  let  src  = OhmForm.from_post_json json in 
  let  form = OhmForm.create ~template ~source:src in

  let fail errors = 
    let  form = OhmForm.set_errors errors form in
    let! json = ohm $ OhmForm.response form in
    return $ Action.json json res
  in
  
  let! result = ohm_ok_or fail $ OhmForm.result form in  

  (* Save the data and process the join request *)

  let! () = ohm $ do_join (access # self) group in 
  let! () = ohm $ save_data (access # self) result in

  return $ Action.javascript (Js.reload ()) res

end

let () = UrlClient.Join.def_ajax $ CClient.action begin fun access req res -> 

  let panic = return $ Action.javascript (Js.reload ()) res in 

  let! arg  = req_or panic (Action.Convenience.get_json req) in 
  let! join = req_or panic (match arg with 
    | Json.Bool join -> Some (`Join join)
    | Json.Null -> Some `Refresh 
    | _ -> None)
  in

  (* Extract the group and entity *)

  let  jid = req # args in 

  let! gid, kind = ohm_req_or panic begin match jid with 
    | `Entity eid -> let! entity = ohm_req_or (return None) $ MEntity.try_get access eid in
		     let! entity = ohm_req_or (return None) $ MEntity.Can.view entity in
		     let  kind = match MEntity.Get.kind entity with
		       | `Group -> `Group
		       | other  -> `Forum
		     in 
		     return $ Some (MEntity.Get.group entity, kind) 
    | `Event eid -> let! event = ohm_req_or (return None) $ MEvent.get ~access eid in
		    let! event = ohm_req_or (return None) $ MEvent.Can.view event in 
		    if MEvent.Get.draft event then return None else
		      return $ Some (MEvent.Get.group event, `Event) 
  end in 

  let! group  = ohm_req_or panic $ MGroup.try_get access gid in 
  let! fields = ohm $ MGroup.Fields.flatten gid in

  let gender = None in 

  (* Determine the action to be taken. *)

  if join <> `Join true || fields = [] then
    
    (* Leaving the entity, refreshing the display, or joining an entity with no form. *)
    
    let! () = ohm begin match join with 
      | `Join false -> MMembership.user gid (access # self) false
      | `Join true  -> do_join (access # self) group
      | `Refresh -> return ()
    end in 

    (* Return the new status. *)

    let! status = ohm $ MMembership.status access gid in
    
    let! html   = ohm $ render jid (access # instance # key) 
      ~gender ~kind ~status ~fields:(fields <> []) in

    return $ Action.json ["replace" , Html.to_json html] res 

  else
    
    (* Joining an entity with a join form *)

    let! status = ohm $ MMembership.status access gid in

    let template = template `Join_Self_Save fields in 
    let form = OhmForm.create ~template ~source:(OhmForm.from_seed (access # self)) in
    let url  = JsCode.Endpoint.of_url (Action.url UrlClient.Join.post req # server req # args) in    

    let! html = ohm $ Asset_Join_SelfEdit.render (object
      method status = css status
      method text   = AdLib.write (label ~gender ~kind ~status)
      method form   = OhmForm.render form url
      method refresh = Action.url req # self req # server req # args
    end) in 

    return $ Action.json ["replace" , Html.to_json html] res 

end
