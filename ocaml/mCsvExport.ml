(* © 2012 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

module Db = CouchDB.Convenience.Config(struct let db = "export" end)
include OhmCouchExport.Make(OhmCouchExport.Csv)(IExport)(Db)

let download id = download (IExport.decay id) 
let state = () 
