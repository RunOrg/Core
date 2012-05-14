(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open MVote_common
module Data = MVote_data

let read t = 
  let! can = ohm t.read in
  if can then return (Some (make_from (IVote.Assert.read t.id) t)) else return None

let vote t = 
  let! can = ohm t.vote in
  if can then return (Some (make_from (IVote.Assert.vote t.id) t)) else return None

let admin t = 
  let! can = ohm t.admin in
  if can then return (Some (make_from (IVote.Assert.admin t.id) t)) else return None
