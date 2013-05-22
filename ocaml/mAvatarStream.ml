(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

(* This should be a subset of the status values in the membership object, excluding
   "NotMember" (and possibly others). *) 
module Status = Fmt.Make(struct
  type json t = 
    [ `Pending
    | `Invited
    | `Member 
    | `Declined ] 
end)

type status = Status.t

module Stream = Fmt.Make(struct
  type json t = [ `Everyone  "e" 
		| `Nobody    "n"
		| `AdminsAnd "a" of (IAvatar.t list * (Status.t * IAvatarSet.t) list)
		| `List      "l" of (IAvatar.t list * (Status.t * IAvatarSet.t) list) 
		]
end)

type t = Stream.t

(* Constructing streams *)

let merge a b = match a, b with 
  | `Everyone, _ | _, `Everyone -> `Everyone
  | `Nobody, x | x, `Nobody -> x
  | `AdminsAnd (a,g), `List (a',g') 
  | `AdminsAnd (a,g), `AdminsAnd (a',g')
  | `List (a,g), `AdminsAnd (a',g') -> `AdminsAnd (a' @ a, g' @ g)
  | `List (a,g), `List (a',g') -> `List (a' @ a, g' @ g)

let canonicalize = function
  | `Everyone -> `Everyone
  | `Nobody -> `Nobody
  | `AdminsAnd (a,g) -> `AdminsAnd (BatList.sort_unique compare a, BatList.sort_unique compare g)
  | `List (a,g) -> `List (BatList.sort_unique compare a, BatList.sort_unique compare g)

let (+) a b = 
  (* This is purely an optimization. *)
  if a <> `Nobody && b <> `Nobody then canonicalize (merge a b) else merge a b 

let union l = 
  canonicalize (List.fold_left merge `Nobody l)

let group sta asid = `List ([],[sta,asid])
let group2 stas asid = `List ([], List.map (fun sta -> sta, asid) stas)
let groups sta asids = `List ([], List.map (fun asid -> sta, asid) asids)
let avatars aids = `List (aids,[])
let everyone = `Everyone
let admins = `AdminsAnd ([],[])
let nobody = `Nobody

(* Letting the rest of the software register stream sources. *)

module Signals = struct
  let is_in_group_call, is_in_group = Sig.make (Run.list_exists identity)
  let all_in_group_call, all_in_group = Sig.make (Run.list_map identity |- Run.map List.concat)
end

(* Iterating through all delegated-to avatars. *)

let fetch iid ?start ~count deleg = 

  let by_status status = 
    let! list, next = ohm $ MAvatar.by_status (IInstance.Deduce.see_contacts iid) ?start ~count status in
    return (match next with None -> list | Some aid -> aid :: list) 
  in
  
  let by_group (sta,gid) = 
    (* We are allowed to access anything the entity needs to get accessors *)
    let gid = IAvatarSet.Assert.list gid in 
    O.decay (Signals.all_in_group_call (iid,sta,gid,start,count))
  in

  let! list = ohm (O.decay begin match deleg with 
    | `Everyone        -> by_status `Token
    | `Nobody          -> return [] 
    | `List      (a,g) -> let! in_groups = ohm (Run.list_map by_group g) in
			  return (List.concat (a :: in_groups))
    | `AdminsAnd (a,g) -> let! in_groups = ohm (Run.list_map by_group g) in
			  let! admins    = ohm (by_status `Admin) in
			  return (List.concat (a :: admins :: in_groups))
			    
  end) in
  
  (* Remove uniques and avatars that occur before the start. If any group-level 
     filtering happened, then there should still be enough elements here to 
     allow for it. 
  *)
  let list = BatList.sort_unique compare list in
  let list = match start with 
    | None -> list
    | Some minaid -> BatList.filter ((<=) minaid) list
  in

  return (OhmPaging.slice ~count list)


module AsyncFmt = Fmt.Make(struct
  type json t = <
    iid    : IInstance.t ;
    aid    : IAvatar.t option ; 
    stream : Stream.t ;
    inner  : Json.t ;
  >
end)

let iter name fmt onItem onEnd = 
  let task, def = O.async # declare name AsyncFmt.fmt in
  let () = def begin fun data -> 
    let! inner = req_or (return ()) (fmt.Fmt.of_json (data # inner)) in
    let  iid   = IInstance.Assert.bot (data # iid) in
    let  start = data # aid in 
    let! list, next = ohm (fetch iid ?start ~count:10 (data # stream)) in
    let! () = ohm (Run.list_iter (onItem inner) list) in
    if next = None then onEnd inner else task (object
      method iid    = data # iid
      method aid    = next
      method stream = data # stream
      method inner  = data # inner
    end)
  end in
  fun iid stream inner -> 
    match stream with 
      | `Nobody -> onEnd inner 
      | `List ([aid],[]) -> let! () = ohm (onItem inner aid) in onEnd inner
      | other -> 
	task (object
	  method iid = IInstance.decay iid
	  method aid = None
	  method stream = stream
	  method inner = fmt.Fmt.to_json inner
	end)

(* Test whether an avatar is part of a set. *)
	  
let in_group aid (sta,asid) = 
  O.decay (Signals.is_in_group_call (aid,sta,asid))

let rec is_in actor = function 
  | `Nobody -> return false
  | `Everyone -> return (MActor.member actor <> None)
  | `AdminsAnd (a,g) -> if MActor.admin actor <> None then return true else is_in actor (`List (a,g))
  | `List (a,g) -> let aid = IAvatar.decay (MActor.avatar actor) in
		   if List.mem aid a then return true else
		     Run.list_exists (in_group aid) g
