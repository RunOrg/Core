(* © 2012 Runorg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

module UsageView = CouchDB.ReduceView(struct
  module Key = Id
  module Value = Fmt.Float
  module Reduced = Fmt.Float
  module Design = MOldFile_common.Design
  let name   = "usage"
  let map    = "if (doc.t == 'file') 
                  for (var v in doc.versions) 
                    { emit(doc.ins ? doc.ins : doc.usr,doc.versions[v].size); }" 
  let reduce = "return sum(values);" 
  let group  = true 
  let level  = None 
end)

let _get_usage id = 
  UsageView.reduce id |> Run.map (BatOption.default 0.)

let instance id = 
  let! used = ohm $ _get_usage (IInstance.to_id id) in
  let! full = ohm $ MInstance.get_free_space id in
  return (used, full)

let max_user_space = 10.0 (* MB *)

let user id = 
  let! used = ohm $ _get_usage (IUser.to_id id) in
  return (used, max_user_space)
