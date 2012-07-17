(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Payload = MNotify_payload

type freq = [ `Immediate | `Daily | `Weekly | `Never ]

type assoc = (MNotifyChannel.t * freq) list
    
type t = <
  default : assoc ; 
  by_iid  : (IInstance.t * assoc) list 
> 

(* Define data types ---------------------------------------------------------------------------------------- *)

module Key = struct
  type t = [ `Default | `Instance of IInstance.t ]
  let to_string = function
    | `Default -> "def"
    | `Instance iid -> IInstance.to_string iid
  let of_string = function
    | "def" -> `Default
    | other -> `Instance (IInstance.of_string other)
end

module Data = Fmt.Make(struct
  type json t = 
      (!Key.t, 
       (MNotifyChannel.t * [ `Immediate "i"
			   | `Daily "d"
			   | `Weekly "w"
			   | `Never "n"]) list) ListAssoc.t
end)

let extract (list : (Key.t * assoc) list) = object
  val default = try List.assoc `Default list with _ -> []
  method default = default
  val by_iid = BatList.filter_map (fun (k,v) -> match k with 
    | `Default -> None
    | `Instance iid -> Some (iid,v)) list
  method by_iid = by_iid
end

include CouchDB.Convenience.Table(struct let db = O.db "notify-freq" end)(IUser)(Data)

(* Implement functions -------------------------------------------------------------------------------------- *)

let get uid = 
  let! list = ohm_req_or (return $ extract []) $ MyTable.get (IUser.decay uid) in
  return $ extract list

let default = function

  | `NewWallItem `WallReader 
  | `NewWallItem `WallAdmin 
  | `NewComment `ItemAuthor
  | `NewComment `ItemFollower
  | `BecomeMember
  | `BecomeAdmin
  | `SuperAdmin -> `Immediate

  | `NewFavorite `ItemAuthor -> `Daily

let compress_assoc assoc = 
  List.filter (fun (k,v) -> default k <> v) assoc

let set uid data = 
  let list = 
    (`Default,compress_assoc (data # default))
    :: List.map (fun (iid,assoc) -> `Instance iid, compress_assoc assoc) (data # by_iid) 
  in
  let! _ = ohm $ MyTable.transaction (IUser.decay uid) (MyTable.insert list) in
  return ()

let assoc channel assoc = 
  try List.assoc channel assoc with Not_found -> default channel

let send _ _ = return `Immediate
