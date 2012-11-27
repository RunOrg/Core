(* © 2012 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

module Db = CouchDB.Convenience.Config(struct let db = O.db "export" end)
include OhmCouchExport.Make(OhmCouchExport.Csv)(IExport)(Db)

let create ?size ?heading () =
  let init = BatOption.map (fun h -> OhmCouchExport.Csv.(add [h] empty)) heading in
  Run.map IExport.Assert.read (create ?size ?init ())

let download id = download (IExport.decay id) 

let state = () 
