(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let items access feed = 
  let! items, _ = ohm $ MItem.list (`feed (MFeed.Get.id feed)) ~count:8 None in
  let! htmls = ohm $ Run.list_filter (CItem.render access) items in 
  return htmls

let feed_rw access feed wfeed = 
  let! items = ohm $ O.decay (items access feed) in 
  O.Box.fill (Asset_Wall_Feed.render (object
    method items = items
  end))

let feed_ro access feed = 
  let! items = ohm $ O.decay (items access feed) in 
  O.Box.fill (Asset_Wall_FeedReadOnly.render (object
    method items = items
  end))

let feed_none () = 
  O.Box.fill (Asset_Wall_NoFeed.render ())

let box access feed =
  match feed with 
    | None -> feed_none () 
    | Some feed -> let! writable = ohm (O.decay (MFeed.Can.write feed)) in
		   match writable with 
		     | None       -> feed_ro access feed
		     | Some wfeed -> feed_rw access feed wfeed
