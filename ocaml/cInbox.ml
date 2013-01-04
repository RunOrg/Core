(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let render_event_line access line eid =
  let! event = ohm_req_or (return None) $ MEvent.view ~actor:(access # actor) eid in
  let! name  = ohm $ MEvent.Get.fullname event in
  let! now   = ohmctx (#time) in
  let! details = ohm $ Run.list_filter identity [

    ( let  name = PreConfig_Template.Events.name (MEvent.Get.template event) in
      let! name = ohm $ AdLib.get (`PreConfig name) in
      return (Some name) ) ;

    ( let! date = req_or (return None) (MEvent.Get.date event) in
      let  ts   = Date.to_timestamp date in
      let! time = ohm $ AdLib.get (`ShortWeekDate (ts,now)) in
      return (Some time) ) ;

  ] in 
  let! html  = ohm $ Asset_Inbox_Line.render (object
    method name = name
    method url  = Action.url UrlClient.Events.see (access # instance # key) [ IEvent.to_string eid ]
    method view = line
    method time = if line # time = 0. then None else Some (line # time, now) 
    method details = details
  end) in
  return (Some html) 

let render_discussion_line access line did =
  let! discn = ohm_req_or (return None) $ MDiscussion.view ~actor:(access # actor) did in
  let  name  = MDiscussion.Get.title discn in
  let! now   = ohmctx (#time) in

  let! details = ohm $ O.decay (Run.list_filter begin fun gid -> 
    let! group = ohm_req_or (return None) $ MGroup.naked_get gid in 
    match MGroup.Get.owner group with 
      | `Event  eid -> return None
      | `Entity eid -> let! entity = ohm_req_or (return None) $ MEntity.try_get (access # actor) eid in
		       let! entity = ohm_req_or (return None) $ MEntity.Can.view entity in 
		       let! name   = ohm (CEntityUtil.name entity) in
		       return (Some name) 
  end (MDiscussion.Get.groups discn)) in 

  let! kind = ohm $ AdLib.get `Inbox_Discussion in 

  let! html  = ohm $ Asset_Inbox_Line.render (object
    method name = name
    method url  = Action.url UrlClient.Discussion.see (access # instance # key) [ IDiscussion.to_string did ]
    method view = line
    method time = if line # time = 0. then None else Some (line # time, now) 
    method details = kind :: details
  end) in
  return (Some html) 

let render_line access line = 
  match line # owner with 
    | `Event      eid -> render_event_line access line eid 
    | `Discussion did -> render_discussion_line access line did 

let () = CClient.define UrlClient.Inbox.def_home begin fun access ->

  O.Box.fill begin 

    let! htmls, next = ohm $ MInboxLine.View.list ~count:10 (access # actor) (render_line access) in
    
    Asset_Inbox_List.render (object
      method items = htmls
    end) 

  end
  
end
