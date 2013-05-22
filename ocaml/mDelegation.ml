(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

(* Signals are used to separate the delegation module from the actual implementation of 
   "avatar is member of group" in the MMembership module. *)

module Signals = struct
  let is_in_group_call, is_in_group = Sig.make (Run.list_exists identity)
end

let in_group aid asid = 
  O.decay (Signals.is_in_group_call (aid,asid)) 

(* Testing presence in list *) 

let rec in_sorted_list item = function 
  | [] -> false
  | x :: xs -> let n = compare x item in 
	       n = 0 || n < 0 && in_sorted_list item xs 

let test actor = function 
  | `Admin      -> return (MActor.admin actor <> None)
  | `Everyone   -> return (MActor.member actor <> None)
  | `Specific s -> let aid = IAvatar.decay (MActor.avatar actor) in
		   if in_sorted_list aid s.IDelegation.avatars then return true else
		     Run.list_exists (in_group aid) s.IDelegation.groups 

(* Merging rights quickly *)

let (+) a b = IDelegation.union a b 

(* Reversal *)

let stream = function 
  | `Admin -> MAvatarStream.admins
  | `Everyone -> MAvatarStream.everyone
  | `Specific s -> MAvatarStream.(let groups = List.map (group `Member) s.IDelegation.groups in
				  union (admins :: avatars s.IDelegation.avatars :: groups)) 
