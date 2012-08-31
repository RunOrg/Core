(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Data = struct
  module T = struct
    type json t = 
	{
	  directory : MAccess.t ;
	 ?events    : MAccess.t = `Admin ; 
	  freeze    : bool 
	}
  end
  include T
  include Fmt.Extend(T)
end

module MyDB = CouchDB.Convenience.Database(struct let db = O.db "instance-access" end)
module Tbl = CouchDB.Table(MyDB)(IInstance)(Data)

let default = Data.({
  directory = `Token ;
  events    = `Token ;
  freeze    = false
})

let get id = 
  let! data = ohm_req_or (return default) $ Tbl.get (IInstance.decay id) in
  return data

let set id data = Tbl.set (IInstance.decay id) data

let update id f = 
  Tbl.Raw.transaction (IInstance.decay id) begin fun id -> 
    let! data_opt = ohm $ Tbl.get id in 
    let  data = BatOption.default default data_opt in 
    let  real = f data in 
    if data = real then return ((),`keep) else return ((),`put real)
  end 

let view_directory id = 
  let! t = ohm $ get (IInstance.decay id) in
  return (MAccess.summarize t.Data.directory)

let can_view_directory ctx = 
  let id = IIsIn.instance (ctx # isin) in
  let! t = ohm $ get (IInstance.decay id) in
  let! allowed = ohm $ MAccess.test ctx [ t.Data.directory ; `Admin ] in
  return (if allowed then Some (IInstance.Assert.see_contacts id) else None)

let create_event id = 
  let! t = ohm $ get (IInstance.decay id) in
  return (MAccess.summarize t.Data.events)

let can_create_event ctx = 
  let id = IIsIn.instance (ctx # isin) in
  let! t = ohm $ get (IInstance.decay id) in
  let! allowed = ohm $ MAccess.test ctx [ t.Data.events ; `Admin ] in
  return (if allowed then Some (IInstance.Assert.create_event id) else None)

let wall_post id = 
  let! t = ohm $ get (IInstance.decay id) in
  return (if t.Data.freeze then `Admin else `Member) 
