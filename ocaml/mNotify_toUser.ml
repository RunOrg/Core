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
  let t_of_json = function
    | Json.Object list ->
      let json = Json.Object (List.filter (function 
	| (_,Json.Array _) -> true
	|  _               -> false) list) in
      t_of_json json
    | json -> t_of_json json
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
  | `EntityInvite
  | `EntityRequest
  | `SuperAdmin -> `Immediate

  | `Broadcast
  | `NewFavorite `ItemAuthor -> `Daily

let compress_assoc assoc = 
  List.filter (fun (k,v) -> default k <> v) assoc

let set uid data = 
  let list = 
    (`Default,compress_assoc (data # default))
    :: List.map (fun (iid,assoc) -> `Instance iid, compress_assoc assoc) (data # by_iid) 
  in
  let list = List.filter (snd |- (<>) []) list in 
  let! _ = ohm $ MyTable.transaction (IUser.decay uid) (MyTable.insert list) in
  return ()

let frequency channel assoc = 
  try List.assoc channel assoc with Not_found -> default channel

let send uid payload =

  let  channel = Payload.channel payload in 
  let! iid     = ohm $ Payload.instance payload in 
  let! options = ohm $ get uid in 

  let  assoc   = match iid with 
    | None -> options # default 
    | Some iid -> try List.assoc iid (options # by_iid) with Not_found -> options # default
  in

  return $ frequency channel assoc

(* Retrieve old data from user notify preferences ----------------------------------------------------------- *)

let restore uid = 
  MyTable.transaction uid begin fun uid -> 
    let! data = ohm $ MyTable.get uid in 
    match data with Some _ -> return ((),`keep) | None -> 
      (* No saved preferences yet, time to build some ! *)
      let! blocks  = ohm $ MUser.blocks uid in 
      let  blocked = List.concat $ List.map (function 
	| `message 
	| `item -> [ `NewWallItem `WallReader ; `NewWallItem `WallAdmin ]  
	| `myMembership -> [ `BecomeMember ; `BecomeAdmin ] 
	| `likeItem -> [ `NewFavorite `ItemAuthor ]
	| `commentItem -> [ `NewComment `ItemAuthor ; `NewComment `ItemFollower ]
	| `welcome -> []
	| `subscription 
	| `event
	| `forum
	| `album
	| `group
	| `poll
	| `course -> [ `EntityInvite ]
	| `pending -> [ `EntityRequest ]
	| `digest -> [ `Broadcast ]
	| `networkInvite
	| `chatReq -> []) blocks
      in
      let blocked = BatList.sort_unique compare blocked in 
      return ( (), `put [`Default,List.map (fun k -> k,`Never) blocked] )
  end
      
let task = Async.Convenience.foreach O.async "notify.migrate.toUser" IUser.fmt
  (MUser.all_ids ~count:20) restore 

(* let () = O.put (task ()) *)
