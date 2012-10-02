(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let items more access feed start = 
  let! items, next = ohm $ MItem.list ~self:(access # self) (`feed (MFeed.Get.id feed)) ~count:8 start in
  let! admin = ohm $ MFeed.Can.admin feed in
  let  moderate = 
    if admin = None then None else 
      Some (Action.url UrlClient.Item.moderate (access # instance # key))  
  in
  let! htmls = ohm $ Run.list_filter (CItem.render ?moderate access) items in 
  let  more  = match next with 
    | None -> None
    | Some time -> Some (OhmBox.reaction_endpoint more time,Json.Null)
  in
  return (htmls, more)

let feed_rw where more access feed wfeed = 

  let! post = O.Box.react Fmt.Unit.fmt begin fun () json _ res -> 
    O.decay $ CItem.post access wfeed json res
  end in

  let sending = match where with 
    | None -> `Everyone
    | Some `Event -> `Event
    | Some `Group -> `Group
    | Some `Forum -> `Forum
  in

  let! mail = ohm begin 
    let! manage = ohm $ O.decay (MFeed.Can.admin feed) in
    return (manage <> None) 
  end in

  O.Box.fill begin 
    let! items, more = ohm $ O.decay (items more access feed None) in 
    Asset_Wall_Feed.render (object
      method url     = OhmBox.reaction_json post ()
      method sending = sending
      method items   = items
      method more    = more
      method mail    = mail
    end)
  end

let feed_ro more access feed = 
  let! items, more = ohm $ O.decay (items more access feed None) in 
  O.Box.fill (Asset_Wall_FeedReadOnly.render (object
    method items = items
    method more  = more
  end))

let feed_none () = 
  O.Box.fill (Asset_Wall_NoFeed.render ())

let getmore access feed = begin fun time _ self res -> 
  let! items, more = ohm $ O.decay (items self access feed (Some time)) in
  let! html = ohm $ Asset_Wall_FeedMore.render (object
    method items = items
    method more  = more
  end) in
  return $ Action.json ["more", Html.to_json html] res
end

let box where access feed =
  match feed with 
    | None -> feed_none () 
    | Some feed -> let! writable = ohm (O.decay (MFeed.Can.write feed)) in
		   let! more = O.Box.react Fmt.Float.fmt (getmore access feed) in 
		   match writable with 
		     | None       -> feed_ro       more access feed
		     | Some wfeed -> feed_rw where more access feed wfeed
