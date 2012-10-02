(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

module Tree = Fmt.Make(struct
  module Float = Fmt.Float
  type json t = <
    what : string ;
    repeat : int ;
    read : int ;
    read_bytes : int ;
    cache_hit : int ;
    write : int ;
    write_bytes: int ;
    start: Float.t ;
    duration: Float.t ;
    children: t list
  >
end)

let version = 1

module Data = Fmt.Make(struct
  module IUser = IUser
  type json t = <
    version : int ;
    url : string ;
    session : string ;
    test : string ;
    user : IUser.t option ;
    server : string option ;
    time : Tree.t
  >
end)

let rec tree_of_profile profile =
  Breathe.Profiling.(object
    method what = profile.what
    method repeat = profile.repeat
    method read = profile.read
    method read_bytes = profile.read_bytes
    method cache_hit = profile.cache_hit
    method write = profile.write
    method write_bytes = profile.write_bytes
    method start = profile.start
    method duration = profile.duration
    method children = List.map tree_of_profile profile.children
  end)

module MyTable = CouchDB.Table(MModel.ProfileAuditDB)(Id)(Data)

let examine ~url ~test ~session ~who ~where profile = 
  MyTable.transaction (Id.gen ()) (MyTable.insert (object
    method version = version 
    method url     = url
    method test    = test
    method session = session 
    method user    = who
    method server  = where
    method time    = tree_of_profile profile
  end)) |> Run.map ignore
    
module All = CouchDB.DocView(struct
  module Key = Id
  module Value = Fmt.Unit
  module Doc = Fmt.Json
  module Design = struct
    module Database = MModel.ProfileAuditDB
    let name = "dump"
  end
  let name = "all"
  let map = "if (doc.version == " ^ (string_of_int version) ^ ") emit(doc._id,null)"
end)

let dump from = 
  
  let size = 101 in

  let query = match from with 
    | None -> All.doc_query ~limit:size ()
    | Some id -> All.doc_query ~limit:size ~startkey:id () 
  in

  let! list = ohm query in

  return begin 
    if List.length list < size then 
      ( list |> List.map Ohm.doc |> Json_type.Build.array, None )
    else
      match List.rev list with 
	| [] -> Json_type.Array [], None
	| h :: t -> 
	  ( t |> List.map Ohm.doc |> Json_type.Build.array,
	    Some (Ohm.key h) )
  end
