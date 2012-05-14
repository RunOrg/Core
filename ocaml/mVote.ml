(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Owner    = MVote_owner

include MVote_common

module Config   = MVote_config
module Question = MVote_question

module Can      = MVote_can
module Stats    = MVote_stats
module Mine     = MVote_mine
module Signals  = MVote_signals
module Get      = MVote_get

(* ---------------------------------------------------------------------------------------- *)

module ByOwner = CouchDB.DocView(struct
  module Key    = Owner
  module Value  = Fmt.Unit
  module Doc    = Vote
  module Design = VoteDesign 
  let name = "by_owner"
  let map  = "emit(doc.o)"
end) 

let by_owner ctx owner = 

  let owner, condition = match owner with 
    | `entity e -> `entity (IEntity.decay (MEntity.Get.id e)), MEntity.Satellite.has_votes e
  in
  
  let! () = true_or (return []) condition in 
  
  let! list = ohm $ ByOwner.doc owner in
  
  return $ List.map (fun item -> make_from_context 
    (item # id |> IVote.of_id) (item # doc) ctx) list
  
let try_get ctx vid = 
  let! data = ohm_req_or (return None) $ VoteTable.get (IVote.decay vid) in
  return $ Some (make_from_context vid data ctx) 

let create ~ctx ~owner ~config ~question ~anonymous = 

  let vid  = IVote.gen () in

  let! time = ohmctx (#time) in

  let! self    = ohm $ ctx # self in
  let  creator = IAvatar.decay self in

  let owner, condition = match owner with 
    | `entity e -> `entity (IEntity.decay (MEntity.Get.id e)), MEntity.Satellite.has_votes e
  in

  let! () = true_or (return ()) condition in

  let data = Vote.({ creator ; owner ; config ; question ; time ; anonymous }) in
  let! _ = ohm $ VoteTable.transaction vid (VoteTable.insert data) in

  let t = make_naked vid data in
  let! () = ohm $ Signals.on_create_call t in

  return ()
  
