(* © 2012 RunOrg *)

open Ohm

(* Database definitions -------------------------------------------------------------------- *)

module MyDB = CouchDB.Convenience.Database(struct let db = O.db "avatar" end)

module Design = struct
  module Database = MyDB
  let name = "avatar"
end

(* Data types & formats -------------------------------------------------------------------- *)


module Data = Fmt.Make(struct
  type json t = <
    (* Definition *)
    t         : MType.t ;
    who       : IUser.t ;
    ins       : IInstance.t ;
    (* Own values *)
    sta       : MAvatar_status.t ;
    (* Cached values *)
    name      : string option ;
    picture   : IOldFile.t option ;
    role      : string option ;
    sort      : string list
  > 
end)

module Tbl = CouchDB.Table(MyDB)(IAvatar)(Data)
