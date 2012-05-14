(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open MNews_common

type t = Payload.t
    
module ByAdminView = CouchDB.DocView(struct
    
  module Key = Fmt.Float
  module Value = Fmt.Unit
  module Doc = Data
  module Design = Design
    
  let name = "by_admin"
  let map  = "if (doc.t == 'news') emit(doc.time,null);"
    
end)
  
let since time = 
  let limit = 30 in
  let! list = ohm $ ByAdminView.doc_query ~endkey:time ~descending:true ~limit () in
  return (List.map (fun item -> item # doc # time , item # doc # payload) list) 
    
module StatsView = CouchDB.DocView(struct

  module Key    = Fmt.Float
  module Value  = Fmt.Unit
  module Doc    = Data
  module Design = Design

  let name = "stats"
  let map  = "emit(doc.time,null)"

end)

let rec query startkey endkey =
  let limit = 50 in 
  let! list = ohm $ StatsView.doc_query ~startkey ~endkey ~limit () in
  if List.length list < limit then return list else
    let first, next = BatList.split_at (limit - 1) list in 
    match next with 
      | [item] -> 
	let! more = ohm $ query (item # key) endkey in
	return (first @ more) 
      | _ -> return list
	
let stats ~day = 
  
  let  dur30 = day -. 30. *. 24. *. 3600. in
  let  dur7  = day -.  7. *. 24. *. 3600. in
  let  dur   = day -.        24. *. 3600. in

  (* Grab 30 days from the database *)
  let! list = ohm $ query dur30 day in
  let  last30 = List.map (#doc) list in
  let  last7  = List.filter (fun d -> d # time >= dur7) last30 in
  let  last   = List.filter (fun d -> d # time >= dur)  last7  in

  let uid_of_aid = 
    Util.memoize (fun aid -> 
      Run.memo begin
	let! details = ohm (MAvatar.details aid) in
	return (details # who)
      end)
  in
      
  let user_info doc =
    let! uid = ohm begin
      match actor doc with 
	| None               -> return None
	| Some (`User   uid) -> return (Some uid)
	| Some (`Avatar aid) -> uid_of_aid aid
    end in
    let active = match doc # payload with 
      | `item _ 
      | `join _
      | `createInstance _
      | `networkConnect _ -> true
      | `login _ -> false
    in 
    return $ Some (active,uid) 
  in

  let! user30 = ohm $ Run.list_filter user_info last30 in
  let! user7  = ohm $ Run.list_filter user_info last7  in
  let! user   = ohm $ Run.list_filter user_info last   in

  let count_uniques list = 
    BatPSet.cardinal 
      (List.fold_left (fun set item -> BatPSet.add item set) BatPSet.empty list)
  in

  let instance_activity list = 
    List.map (#instance) 
      (List.filter (fun doc -> match doc # payload with
	| `login _ | `createInstance _ | `item _ -> true
	| `join  _ | `networkConnect _ -> false) list)
  in 

  let user_activity list = 
    List.map snd (List.filter fst list) 
  in

  let user_login list = 
    List.map snd list
  in

  let messages list = 
    List.length 
      (List.filter (fun doc -> match doc # payload with 
	| `item _ -> true
	| _ -> false) list)
  in

  return (object

    val ins30 = count_uniques (instance_activity last30)
    method active_instances_30 = ins30

    val ins7  = count_uniques (instance_activity last7) 
    method active_instances_7  = ins7
    
    val ins   = count_uniques (instance_activity last) 
    method active_instances    = ins

    val usr30 = count_uniques (user_activity user30) 
    method active_users_30 = usr30

    val usr7  = count_uniques (user_activity user7) 
    method active_users_7  = usr7

    val usr   = count_uniques (user_activity user) 
    method active_users    = usr

    val log30 = count_uniques (user_login user30) 
    method logins_30 = log30

    val log7  = count_uniques (user_login user7) 
    method logins_7  = log7

    val log   = count_uniques (user_login user) 
    method logins    = log

    val msg30 = messages last30
    method messages_30 = msg30

    val msg7  = messages last7
    method messages_7  = msg7

    val msg   = messages last
    method messages    = msg

  end)
