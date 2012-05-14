(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open MVote_common

let set vote self answers = 

  let! now = ohmctx (#time) in

  let! () = true_or (return false) 
    (List.length answers = 1 || vote.data.Vote.question # multiple) in
    
  let max_answer = List.length (vote.data.Vote.question # answers) - 1 in 

  let! () = true_or (return false)
    (List.for_all (fun i -> i >= 0 && i <= max_answer) answers) in

  let! () = true_or (return false)
    (match vote.data.Vote.config # closed_on with 
      | None   -> true
      | Some t -> t > now) in

  let! () = true_or (return false)
    (match vote.data.Vote.config # opened_on with 
      | None   -> true
      | Some t -> t < now) in

  let vid = vote.id in
  let! () = ohm $ ballot_update self vid 
    (fun b -> return (Some Ballot.({ b with answers = answers }))) in

  return true

let get vote self = 
  let! ballot = ohm_req_or (return None) $ ballot_get self vote.id in 
  return $ Some ballot.Ballot.answers
