(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Data = struct
  module T = struct
    type json t = 
	{
	  directory : MAccess.t ;
	  freeze    : bool 
	}
  end
  include T
  include Fmt.Extend(T)
end

module MyDB = MModel.Register(struct let db = "instance-access" end)
module MyTable = CouchDB.Table(MyDB)(IInstance)(Data)

let default = Data.({
  directory = `Token ;
  freeze    = false
})

let get id = 
  let! data = ohm_req_or (return default) $ MyTable.get (IInstance.decay id) in
  return data

let set id data = 
  let! _ = ohm $ MyTable.transaction (IInstance.decay id) (MyTable.insert data) in
  return ()

let view_directory id = 
  let! t = ohm $ get (IInstance.decay id) in
  return (MAccess.summarize t.Data.directory)

let can_view_directory ctx = 
  let id = IIsIn.instance (ctx # myself) in
  let! t = ohm $ get (IInstance.decay id) in
  let! allowed = ohm $ MAccess.test ctx [ t.Data.directory ; `Admin ] in
  return (if allowed then Some (IInstance.Assert.see_contacts id) else None)

let wall_post id = 
  let! t = ohm $ get (IInstance.decay id) in
  return (if t.Data.freeze then `Admin else `Token) 
