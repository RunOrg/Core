(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Versioned = MMembership_versioned
module Unique    = MMembership_unique 
module Diff      = MMembership_diff

module CountView = CouchDB.ReduceView(struct
  module Key     = Fmt.Unit
  module Value   = Fmt.Int
  module Reduced = Fmt.Int
  module Design  = Versioned.Design
  let name   = "backdoor-count"
  let map    = "emit(null,1);"
  let reduce = "return sum(values);"
  let group  = true
  let level  = None
end)
  
let count () = 
  let! list = ohm $ CountView.reduce_query () in
  match list with 
    | ( _, v ) :: _ -> return v 
    |   _           -> return 0
  
let make_admin aid iid = 
  
  let namer = MPreConfigNamer.load iid in 
  
  let!  gid = ohm $ MPreConfigNamer.group "admin" namer in
  
  let!    _ = ohm $ Versioned.apply gid aid
    [ Diff.admin aid true ; Diff.user aid true ]
  in
  
  return ()
