(* © 2013 RunOrg *)
  
open Ohm
open Ohm.Universal
open BatPervasives
  
module E    = DMS_MDocument_core
module Can  = DMS_MDocument_can

module IRepository = DMS_IRepository

include HEntity.Set(Can)(E)

let name name t self =
  let e = Can.data t in 
  if name = e.E.name then return () else 
    update [ `SetName name ] t self

let share rid t self = 
  let rid = IRepository.decay rid in 
  let e = Can.data t in 
  if List.mem rid e.E.repos then return () else
    update [`Share rid] t self

let unshare rid t self = 
  let rid = IRepository.decay rid in 
  let e = Can.data t in 
  if not (List.mem rid e.E.repos) then return () else
    update [`Unshare rid] t self

