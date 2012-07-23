(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let css_invited = "-invited"
let css_none    = "-none"
let css_joined  = "-joined"

let render eid key ~gender ~kind ~status ~fields = 

  let action what = object
    method url  = Action.url UrlClient.Join.ajax key eid  
    method data = Json.Bool what
  end in

  let label, css, buttons = match status with 
    | `NotMember -> begin
      let label = match kind with 
	| `Event -> `Join_Self_Event_NotMember gender
	| _      -> `Join_Self_Group_NotMember gender
      in
      (label,css_none,[(object
	method green = true
	method label = AdLib.write (if fields then `Join_Self_JoinEdit else `Join_Self_Join)
	method action = action true
      end)])
    end
    | `Member -> begin
      let label = match kind with 
	| `Event -> `Join_Self_Event_Member gender
	| `Forum -> `Join_Self_Forum_Member gender
	| _      -> `Join_Self_Group_Member gender
      in
      let cancel = object 
	method green = false
	method label = AdLib.write `Join_Self_Cancel
	method action = action false
      end in 
      (label,css_joined,
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
      )
    end
    | `Invited -> begin
      (`Join_Self_Event_Invited gender,css_invited,[
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
      ])
    end
    | `Pending -> begin
      (`Join_Self_Pending gender,css_joined,[
	(object
	  method green = false
	  method label = AdLib.write `Join_Self_Cancel
	  method action = action false
	 end)
      ])
    end
    | `Unpaid -> begin
      (`EMPTY,css_none,[])
    end
    | `Declined -> begin
      (`Join_Self_Event_NotMember gender,css_none,[(object
	method green = true
	method label = AdLib.write (if fields then `Join_Self_JoinEdit else `Join_Self_Join)
	method action = action true
      end)])
    end
  in

  Asset_Join_Self.render (object
    method status = css
    method text = AdLib.write label
    method buttons = buttons
  end)


let () = UrlClient.Join.def_ajax $ CClient.action begin fun access req res -> 

  let panic = return $ Action.javascript (Js.reload ()) res in 

  let! arg  = req_or panic (Action.Convenience.get_json req) in 
  let! join = req_or panic (match arg with 
    | Json.Bool join -> Some join
    | _ -> None)
  in

  (* Extract the group and entity *)

  let  eid    = req # args in 
  let! entity = ohm_req_or panic $ MEntity.try_get access eid in
  let! entity = ohm_req_or panic $ MEntity.Can.view entity in

  let! () = true_or panic (not (MEntity.Get.draft entity)) in 
  
  let  gid   = MEntity.Get.group entity in
  let! group = ohm_req_or panic $ MGroup.try_get access gid in

  let  kind = match MEntity.Get.kind entity with
    | `Event -> `Event
    | `Group -> `Group
    | other  -> `Forum
  in 

  let! status = ohm $ MMembership.status access gid in
  let  fields = MGroup.Fields.get group <> [] in

  let! html   = ohm $ render eid (access # instance # key) ~gender:None ~kind ~status ~fields in
  return $ Action.json ["replace" , Html.to_json html] res 

    
end
