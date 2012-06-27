(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let feed_rw feed = 
  O.Box.fill (Asset_Wall_Feed.render (object
    method items = []
  end))

let feed_ro feed = 
  O.Box.fill (Asset_Wall_FeedReadOnly.render (object
    method items = []
  end))

let feed_none () = 
  O.Box.fill (Asset_Wall_NoFeed.render ())

let box feed =
  match feed with 
    | None -> feed_none () 
    | Some feed -> let! writable = ohm (O.decay (MFeed.Can.write feed)) in
		   match writable with 
		     | None      -> feed_ro feed
		     | Some feed -> feed_rw feed
