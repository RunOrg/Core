(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let do_join self group =   
  let! admin = ohm $ MGroup.Can.write group in   
  match admin with
    | None -> MMembership.user (MGroup.Get.id group) self true 
    | Some group -> MMembership.admin ~from:self (MGroup.Get.id group) self [ `Accept true ; `Default true ]
 

let template fields = 
  List.fold_left (fun acc field -> 
    acc |> OhmForm.append (fun json result -> return $ (field # name,result) :: json)
	begin match field # edit with 
	  | `Checkbox
	  | `Date
	  | `LongText
	  | `PickMany _ 
	  | `PickOne  _ 
	  | `Textarea ->
	    (VEliteForm.textarea 
	       ~label:(TextOrAdlib.to_string (field # label))
	       (fun data -> return begin 
		 try Json.to_string (List.assoc (field # name) data)
		 with _ -> ""
	       end)
	       (fun field data -> return $ Ok (Json.String data))) 
	end 
  ) (OhmForm.begin_object []) fields

  |> VEliteForm.with_ok_button ~ok:(AdLib.get `Join_Self_Save)

let css_invited = "-invited"
let css_none    = "-none"
let css_joined  = "-joined"

let label ~gender ~kind ~status = 
  match status with 
    | `NotMember -> begin
      match kind with 
	| `Event -> `Join_Self_Event_NotMember gender
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
    | `Declined -> `Join_Self_Event_NotMember gender

let css = function
  | `NotMember -> css_none
  | `Member    -> css_joined
  | `Invited   -> css_invited
  | `Pending   -> css_joined
  | `Unpaid    -> css_none
  | `Declined  -> css_none

let render eid key ~gender ~kind ~status ~fields = 

  let action what = object
    method url  = Action.url UrlClient.Join.ajax key eid  
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

  let  eid    = req # args in 
  let! entity = ohm_req_or panic $ MEntity.try_get access eid in
  let! entity = ohm_req_or panic $ MEntity.Can.view entity in

  let! () = true_or panic (not (MEntity.Get.draft entity)) in 
  
  let  gid   = MEntity.Get.group entity in
  let! group = ohm_req_or panic $ MGroup.try_get access gid in

  (* Extract form data *)

  let! json = req_or panic $ Action.Convenience.get_json req in

  let  src  = OhmForm.from_post_json json in 
  let  form = OhmForm.create ~template:(template (MGroup.Fields.get group)) ~source:src in

  let fail errors = 
    let  form = OhmForm.set_errors errors form in
    let! json = ohm $ OhmForm.response form in
    return $ Action.json json res
  in
  
  let! result = ohm_ok_or fail $ OhmForm.result form in  

  (* Save the data and process the join request *)

  let! ()    = ohm $ do_join (access # self) group in 
  
  let  info = MUpdateInfo.info ~who:(`user (Id.gen (), IAvatar.decay (access # self))) in
  let! mid  = ohm $ MMembership.as_user gid (access # self) in
  let! ()   = ohm $ MMembership.Data.self_update gid (access # self) info result in

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

  let  eid    = req # args in 
  let! entity = ohm_req_or panic $ MEntity.try_get access eid in
  let! entity = ohm_req_or panic $ MEntity.Can.view entity in

  let! () = true_or panic (not (MEntity.Get.draft entity)) in 
  
  let  gid   = MEntity.Get.group entity in
  let! group = ohm_req_or panic $ MGroup.try_get access gid in

  let  fields = MGroup.Fields.get group in

  let  kind = match MEntity.Get.kind entity with
    | `Event -> `Event
    | `Group -> `Group
    | other  -> `Forum
  in 

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
    
    let! html   = ohm $ render eid (access # instance # key) 
      ~gender ~kind ~status ~fields:(fields <> []) in

    return $ Action.json ["replace" , Html.to_json html] res 

  else
    
    (* Joining an entity with a join form *)

    let! mid    = ohm $ MMembership.as_user gid (access # self) in
    let! status = ohm $ MMembership.status access gid in
    let! data   = ohm $ MMembership.Data.get mid in 

    let form = OhmForm.create ~template:(template fields) ~source:(OhmForm.from_seed data) in
    let url  = JsCode.Endpoint.of_url (Action.url UrlClient.Join.post req # server req # args) in    

    let! html = ohm $ Asset_Join_SelfEdit.render (object
      method status = css status
      method text   = AdLib.write (label ~gender ~kind ~status)
      method form   = OhmForm.render form url
      method refresh = Action.url req # self req # server req # args
    end) in 

    return $ Action.json ["replace" , Html.to_json html] res 

end
