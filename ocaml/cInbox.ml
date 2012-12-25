(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let render_event_line access line eid =
  let! event = ohm_req_or (return None) $ MEvent.view ~actor:(access # actor) eid in
  let! name  = ohm $ MEvent.Get.fullname event in
  let! now   = ohmctx (#time) in
  let! html  = ohm $ Asset_Inbox_Line.render (object
    method name = name
    method url  = Action.url UrlClient.Events.see (access # instance # key) [ IEvent.to_string eid ]
    method view = line
    method time = if line # time = 0. then None else Some (line # time, now) 
  end) in
  return (Some html) 

let render_line access line = 
  match line # owner with 
    | `Event eid -> render_event_line access line eid 

let () = CClient.define UrlClient.Inbox.def_home begin fun access ->

  O.Box.fill begin 

    let! htmls, next = ohm $ MInboxLine.View.list ~count:10 (access # actor) (render_line access) in
    
    Asset_Inbox_List.render (object
      method items = htmls
    end) 

  end
  
end
