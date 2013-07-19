(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Data = struct
  module T = struct
    type json t = 
	{
	 ?events    : IDelegation.t = `Admin ; 
	 ?search    : IDelegation.t = `Everyone ; 
	}
  end
  include T
  include Fmt.Extend(T)
end

module MyDB = CouchDB.Convenience.Database(struct let db = O.db "instance-access" end)
module Tbl = CouchDB.Table(MyDB)(IInstance)(Data)

let default = Data.({
  events    = `Everyone ;
  search    = `Everyone ; 
})

let get id = 
  let! data = ohm_req_or (return default) $ Tbl.get (IInstance.decay id) in
  return data

let update id f = 
  Tbl.Raw.transaction (IInstance.decay id) begin fun id -> 
    let! data_opt = ohm $ Tbl.get id in 
    let  data = BatOption.default default data_opt in 
    let  real = f data in 
    if data = real then return ((),`keep) else return ((),`put real)
  end 

let can_create_event actor = 
  let iid = MActor.instance actor in 
  let! t = ohm $ get (IInstance.decay iid) in
  let! allowed = ohm $ MDelegation.test actor t.Data.events in
  return (if allowed then Some (IInstance.Assert.create_event iid) else None)

let can_search_atoms actor = 
  let iid = MActor.instance actor in 
  let! t = ohm $ get (IInstance.decay iid) in
  let! allowed = ohm $ MDelegation.test actor t.Data.search in
  return (if allowed then Some (IInstance.Assert.search_atoms iid) else None)
