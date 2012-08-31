(* © 2012 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

module Export = MCsvExport

let start gid =   
  let! size = ohm (Run.map (#any) (MMembership.InGroup.count gid)) in
  let! exid = ohm $ Export.create ~size () in
  return exid
