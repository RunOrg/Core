(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

module Data    = MInstance_data

(* Database definition --------------------------------------------------------------------- *)

module MyDB = MModel.InstanceDB
module Design = struct
  module Database = MyDB
  let name = "instance"
end

(* Define the internal data type ----------------------------------------------------------- *)

module MyTable = CouchDB.Table(MyDB)(IInstance)(Data)

let get_raw iid = 
  MyTable.get (IInstance.decay iid) 
