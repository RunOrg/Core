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
