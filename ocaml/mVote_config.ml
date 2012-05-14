(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open MVote_common
module Data = MVote_data

type t = Data.Config.t

let create ?closed ?opened () = object
  method closed_on = closed
  method opened_on = opened
end

let get t = t.data.Vote.config

let set t config = 
  let vid = IVote.decay t.id in 
  let update vote = Vote.({ vote with config }) in
  let! _ = ohm $ VoteTable.transaction vid (VoteTable.update update) in
  return ()

let close t = 
  let vid = IVote.decay t.id in 
  let! now = ohmctx (#time) in
  let update vote = 
    Vote.({
      vote with config = 
	(object
	  method closed_on = Some now
	  method opened_on = vote.config # opened_on 
	 end)
    }) 
  in
  let! _ = ohm $ VoteTable.transaction vid (VoteTable.update update) in
  return ()
    
