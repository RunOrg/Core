(* © 2013 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

module E         = DMS_MDocument_core
module Can       = DMS_MDocument_can 

include HEntity.Atom(Can)(E)(struct
  type t = E.t
  let key    = "dms-document"
  let nature = `DMS_Document
  let limited _ = true
  let hide    _ = false
  let name    t = return t.E.name
end) 
