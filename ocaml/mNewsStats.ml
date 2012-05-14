(* (c) 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module MyDB = MModel.Register(struct let db = "news-stats" end)
module Design = struct
  module Database = MyDB
  let name = "stats"
end

(* Data types and table definition ------------------------------------------------------- *)

module Stats = Fmt.Make(struct

  type t = <
    active_instances_30 : int ;
    active_instances_7  : int ;
    active_instances    : int ;
    active_users_30 : int ;
    active_users_7  : int ;
    active_users    : int ;
    logins_30 : int ;
    logins_7  : int ;
    logins    : int ;
    messages_30 : int ;
    messages_7  : int ;
    messages    : int
  > ;;

  let t_of_json json = 
    match Json_type.Browse.list Json_type.Browse.int json with 
      | [ ai30 ; ai7 ; ai ; au30 ; au7 ; au ; l30 ; l7 ; l ; m30 ; m7 ; m ] -> 
	(object
	  method active_instances_30 = ai30
	  method active_instances_7  = ai7 
	  method active_instances    = ai
	  method active_users_30 = au30
	  method active_users_7  = au7
	  method active_users    = au
	  method logins_30 = l30
	  method logins_7  = l7
	  method logins    = l
	  method messages_30 = m30
	  method messages_7  = m7
	  method messages    = m
	 end)
      | _ -> failwith "Incorrect list size for NewsStats"

  let json_of_t t = 
    Json_type.Build.list Json_type.Build.int [
      t # active_instances_30 ;
      t # active_instances_7  ;
      t # active_instances    ;
      t # active_users_30 ;
      t # active_users_7  ;
      t # active_users    ;
      t # logins_30 ;
      t # logins_7  ;
      t # logins    ;
      t # messages_30 ;
      t # messages_7  ;
      t # messages    ;
    ]

end)

module Data = Fmt.Make(struct
  type json t = < d : Stats.t >
end)

module MyTable = CouchDB.Table(MyDB)(Id)(Data) 

let id_of_date time = Id.of_string (MFmt.date_of_float time) 

(* Computing and writing the data for a day. ---------------------------------------------- *)

let grab cache time = 
  let  id    = id_of_date time in
  try  return (id, BatPMap.find id cache) 
  with Not_found ->  
    let! stats = ohm $ MNews.Backdoor.stats time in
    let  data  = object method d = stats end in
    let! _     = ohm $ MyTable.transaction id (MyTable.insert data) in
    ( Util.log "NewsStats : caching %s" (Id.str id) ;
      return (id, stats) )

(* Reading the entire data from database into a cache ------------------------------------ *)

module AllView = CouchDB.MapView(struct
  module Key    = Fmt.Unit
  module Value  = Stats
  module Design = Design 
  let name = "all"
  let map  = "emit(null,doc.d)"
end)

let cache () = 
  let! list = ohm $ AllView.query () in
  return $ List.fold_left 
    (fun map item -> BatPMap.add (item # id) (item # value) map) BatPMap.empty list

(* Extracting all the days from the database since 01/08/2011 --------------------------- *) 

let start_day = 1312174800.0 (* 01/08/2011 *)

let extract () = 

  let! now   = ohmctx (#time) in
  let! cache = ohm $ cache () in

  let rec read accum day = 
    Util.log "NewsStats : processing day %s" (MFmt.date_of_float day) ;
    if day > now then return $ List.rev_map (fun (a,b) -> Id.str a, b) accum else 
      let! id, data = ohm $ grab cache day in 
      read ((id, data) :: accum) (day +. 3600. *. 24.) 
  in

  read [] start_day
