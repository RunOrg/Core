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
    let! group = ohm_req_or (return None) $ MAvatarSet.naked_get gid in 
    match MAvatarSet.Get.owner group with 
      | `Event  eid -> return None
      | `Group  gid -> let! group  = ohm_req_or (return None) $ MGroup.view ~actor:(access # actor) gid in
		       let! name   = ohm (MGroup.Get.fullname group) in
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

let render_list ?start ~count filter access more = 
  let! items, next = ohm $ MInboxLine.View.list 
    ?start ~filter ~count (access # actor) (render_line access) in  
  let  more = BatOption.map (fun next -> OhmBox.reaction_endpoint more next, Json.Null) next in
  Asset_Inbox_List_Inner.render (object
    method items = items
    method more  = more
  end) 

let () = CClient.define UrlClient.Inbox.def_home begin fun access ->

  let! filter = O.Box.parse IInboxLine.Filter.seg in

  let! more = O.Box.react Fmt.Float.fmt begin fun start _ self res ->
    let! html = ohm $ render_list ~start ~count:8 filter access self in
    return $ Action.json [ "more", Html.to_json html ] res
  end in 

  O.Box.fill begin 

    let new_discussion = Action.url UrlClient.Discussion.create (access # instance # key) [] in
    let new_event = Action.url UrlClient.Events.create (access # instance # key) [] in

    let! filters = ohm $ MInboxLine.View.filters (access # actor) in

    let! filters = ohm $ O.decay (Run.list_filter begin fun (f',count) -> 

      (* Filter name : extract from group, or display static *)
      let! name = ohm_req_or (return None) begin 
	let static f = let! name = ohm (AdLib.get (`Inbox_Filter f)) in return (Some name) in
	match f' with 
	  | `All       -> static `All
	  | `Events    -> static `Events
	  | `Groups    -> static `Groups
	  | `HasPics   -> static `HasPics
	  | `HasFiles  -> static `HasFiles
	  | `Private   -> static `Private
	  | `Group gid -> let! group = ohm_req_or (return None) $ MGroup.view ~actor:(access # actor) gid in 
			  let! name  = ohm $ MGroup.Get.fullname group in 
			  return (Some name) 
      end in 

      let url = Action.url UrlClient.Inbox.home (access # instance # key) [ IInboxLine.Filter.to_string f' ] in

      let sort = 
	let rank = match f' with 
	  | `All      -> 0
	  | `Private  -> 1
	  | `HasFiles -> 2 
	  | `HasPics  -> 3
	  | `Events   -> 4
	  | `Groups   -> 5
	  | `Group _  -> 6
	in
	let name = Util.fold_all name in
	rank, name
      in

      (* Actual rendering *) 
      return $ Some (object
	method sort = sort
	method name = name
	method count = count
	method depth = match f' with 
	  | `All     -> 0 
	  | `Private 
	  | `HasFiles 
	  | `HasPics
	  | `Events
	  | `Groups  -> 1
	  | `Group _ -> 2
	method sel  = filter = f'
	method url  = url 
      end)

    end filters) in 

    (* Sort groups by name *)
    let filters = List.sort (fun a b -> compare (a # sort) (b # sort)) filters in

    (* Determine if an admin *)
    let admin = match CAccess.admin access with 
      | None -> None
      | Some _ -> Some (object method gender = None end)
    in
					 
    Asset_Inbox_List.render (object     
      method actions = object
	method new_discussion = new_discussion
	method new_event = new_event
      end 
      method admin = admin
      method filters = filters
      method inner = render_list ~count:0 filter access more
    end) 

  end
  
end
