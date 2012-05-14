(* © 2012 RunOrg *)

val create :            
  ctx:'a CContext.full ->
  config:CItem.config ->
  feed:[ `Write ] MFeed.t ->
  feed_hid:Js.id ->
  (O.Box.reaction -> 'b O.box) -> 'b O.box 
