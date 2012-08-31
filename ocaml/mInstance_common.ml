(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

module Data    = MInstance_data

(* Database definition --------------------------------------------------------------------- *)

module MyDB = CouchDB.Convenience.Database(struct let db = O.db "instance" end)
module Design = struct
  module Database = MyDB
  let name = "instance"
end

(* Define the internal data type ----------------------------------------------------------- *)

module Tbl = CouchDB.Table(MyDB)(IInstance)(Data)

let get_raw iid = 
  Tbl.get (IInstance.decay iid) 
