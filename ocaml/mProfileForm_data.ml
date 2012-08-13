(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

type data = (string * Json.t) list 

module Config = struct

  let name = "profile-form-data"
  module Id = IProfileForm
  module DataDB = CouchDB.Convenience.Config(struct let db = O.db "profile-form-d" end)
  module VersionDB = CouchDB.Convenience.Config(struct let db = O.db "profile-form-d-v" end) 
  module Data = Fmt.Make(struct type json t = (!string,Json.t) ListAssoc.t end)
  module Diff = Data
  module VersionData = MUpdateInfo
  module ReflectedData = Fmt.Unit

  type ctx = O.ctx
  let couchDB ctx = (ctx :> CouchDB.ctx) 

  let apply list = 
    return (fun _ _ t -> 
      return $ List.fold_left (fun t (k,v) -> ListAssoc.replace k v t) t list)
      
  let reflect _ _ = return ()

end

module Store = OhmCouchVersioned.Make(Config) 
module Table = CouchDB.ReadTable(Store.DataDB)(IProfileForm)(Store.Raw)

let set pfid info data = 
  let! _ = ohm $ Store.create ~id:(IProfileForm.decay pfid) ~init:[] ~diffs:[data] ~info () in
  return () 

let get pfid = 
  let! item = ohm_req_or (return []) $ Table.get (IProfileForm.decay pfid) in
  return (item # current) 
