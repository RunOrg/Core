(* © 2012 RunOrg *)

type 'a source = 
  [ `feed   of 'a IFeed.id 
  | `album  of 'a IAlbum.id
  | `folder of 'a IFolder.id ]

val decay : 'a source -> [`Unknown] source

val to_id : 'a source -> Ohm.Id.t
