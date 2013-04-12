(* © 2013 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

module Core = MMail_core
module All  = MMail_all

module InstanceSet = Fmt.Make(struct
  type t = IInstance.t BatPSet.t
  let json_of_t s =
    Json.of_list IInstance.to_json 
      (BatPSet.fold (fun x xs -> x :: xs) s [])
  let t_of_json l = 
    BatPSet.of_list 
      (Json.to_list IInstance.of_json l) 
end)

module Data = struct
  module T = struct
    type json t = {
      bounced : bool ;
      allowed : InstanceSet.t ;
      blocked : InstanceSet.t ; 
    }
  end
  include T
  include Fmt.Extend(T)
end

let default = Data.({
  bounced = false ;
  allowed = BatPSet.empty ;
  blocked = BatPSet.empty ;
})

let do_bounce t = 
  if t.Data.bounced then t else 
    Data.({ t with bounced = true })

let do_allow iid t = 
  if BatPSet.mem iid t.Data.allowed then t else 
    Data.({ t with 
      allowed = BatPSet.add iid t.allowed ;
      blocked = BatPSet.remove iid t.blocked ;
    })

let do_block iid t = 
  if BatPSet.mem iid t.Data.blocked then t else 
    Data.({ t with 
      allowed = BatPSet.remove iid t.allowed ;
      blocked = BatPSet.add iid t.blocked
    })

include CouchDB.Convenience.Table(struct let db = O.db "mail-user" end)(IUser)(Data) 

let get uid iid = 
  let iid = IInstance.decay iid and uid = IUser.decay uid in 
  let! status = ohm_req_or (return None) (Tbl.get uid) in
  if BatPSet.mem iid status.Data.allowed then return (Some true)
  else if BatPSet.mem iid status.Data.blocked then return (Some false)
  else return None

let can_send uid = 
  let! status = ohm_req_or (return true) (Tbl.get (IUser.decay uid)) in
  return (not status.Data.bounced)

let apply uid f = 
  Tbl.transact (IUser.decay uid) (fun t ->
    let t  = BatOption.default default t in
    let t' = f t in
    if t == t' then return (false,`keep) else return (true,`put t'))

let set ?mid uid iid allow = 
  let! changed = ohm (apply uid ((if allow then do_allow else do_block) (IInstance.decay iid))) in
  if changed then 
    let! mid = req_or (return()) mid in 
    Core.accepted mid allow
  else
    return () 

let bounce uid = 
  Run.map ignore (apply uid do_bounce)

let max_silent_emails = 3

let attitude uid iid = 
  let  iid = IInstance.decay iid and uid = IUser.decay uid in 
  let! status = ohm (Tbl.get uid) in
  let  status = BatOption.default default status in 
  if status.Data.bounced then return `Bounced else
    if BatPSet.mem iid status.Data.blocked then return `Blocked else
      if BatPSet.mem iid status.Data.allowed then return `Allowed else
	let! confirmed = ohm (O.decay (MUser.confirmed uid)) in
	if confirmed then return `NewContact else
	  let! silent = ohm (All.silent uid iid) in
	  if silent > max_silent_emails then return `Blocked else 
	    return (`Silent silent)

type attitude = 
  [ `Blocked 
  | `Bounced
  | `Allowed
  | `NewContact (* User is confirmed but did not allow the instance yet. *)
  | `Silent of int (* Unconfirmed user receiving unread e-mail *) 
  ]
