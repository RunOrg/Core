(* © 2012 RunOrg *)

type 'a source = 
  [ `feed   of 'a IFeed.id 
  | `album  of 'a IAlbum.id
  | `folder of 'a IFolder.id ]

let decay = function 
  | `feed   id -> `feed   (IFeed.decay   id) 
  | `album  id -> `album  (IAlbum.decay  id)
  | `folder id -> `folder (IFolder.decay id)

let to_id = function
  | `feed   id -> IFeed.to_id   id 
  | `album  id -> IAlbum.to_id  id
  | `folder id -> IFolder.to_id id
