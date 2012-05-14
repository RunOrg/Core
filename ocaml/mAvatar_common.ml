(* © 2012 MRunOrg *)

open Ohm

(* Database definitions -------------------------------------------------------------------- *)

module MyDB = MModel.AvatarDB

module Design = struct
  module Database = MyDB
  let name = "avatar"
end

(* Data types & formats -------------------------------------------------------------------- *)

module PUser     = IUser
module PInstance = IInstance
module PGroup    = IGroup
module PAvatar   = IAvatar
module IFile     = IFile
module Json      = Fmt.Json
module Float     = Fmt.Float

module Data = Fmt.Make(struct
  type json t = <
    (* Definition *)
    t         : MType.t ;
    who       : PUser.t ;
    ins       : PInstance.t ;
    (* Own values *)
    sta       : MAvatar_status.t ;
    (* Cached values *)
    name      : string option ;
    picture   : IFile.t option ;
    role      : string option ;
    sort      : string list
  > 
end)

module MyTable = CouchDB.Table(MyDB)(IAvatar)(Data)
