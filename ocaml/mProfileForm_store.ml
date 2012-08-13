(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

module Info = MProfileForm_info 

module InfoDiff = Fmt.Make(struct
  type json t = 
    [ `Name   "n" of string
    | `Hiding "h" of bool
    | `Author "a" of IAvatar.t ]
end)

module Config = struct

  let name = "profile-form"
  module Id = IProfileForm
  module DataDB = CouchDB.Convenience.Config(struct let db = O.db "profile-form" end)
  module VersionDB = CouchDB.Convenience.Config(struct let db = O.db "profile-form-v" end)
  module Data = Info
  module Diff = InfoDiff
  module VersionData = MUpdateInfo
  module ReflectedData = Fmt.Unit

  type ctx = O.ctx
  let couchDB ctx = (ctx :> CouchDB.ctx)

  let apply = function
    | `Name   name   -> return (fun id time t -> return Info.({ t with name }))
    | `Hiding hidden -> return (fun id time t -> return Info.({ t with hidden }))
    | `Author aid    -> return (fun id time t -> return Info.({ t with updated = Some (time,aid) }))

  let reflect _ _ = return () 

end

include OhmCouchVersioned.Make(Config) 

module Design = struct
  module Database = DataDB
  let name = "form"
end
