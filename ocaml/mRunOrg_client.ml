(* © 2012 MRunOrg *)

open Ohm
open Ohm.Util
open Ohm.Universal
open BatPervasives

module MyDB = CouchDB.Convenience.Database(struct let db = O.db "runorg-client" end)

module O = MRunOrg_order.Data

module Design = struct
  module Database = MyDB
  let name = "client"
end

module Data = struct
  module T = struct
    module IOffer = IRunOrg.Offer
    type json t = {
      seats     : int ;
      memory    : int ;
      first_day : int ;
      last_day  : int ;
      daily     : (int * int) ;
      joined    : int ;
      instance  : IInstance.t ;
     ?offer     : IOffer.t option ; 
     ?mem_offer : IOffer.t option ;
     ?name      : string = "";
     ?address   : string = ""
    }
  end
  include T
  include Fmt.Extend(T)
end 

module Signals = struct
  let update_call, update = Sig.make (Run.list_iter identity)
end

module MyTable = CouchDB.Table(MyDB)(IRunOrg.Client)(Data)

let fresh first instance =
  Data.({
    seats     =  0 ;
    memory    = 50 ;
    joined    = first ;
    daily     = 0, 365 ;
    first_day = first - 1 ;   
    last_day  = first - 1 ;
    instance  = instance ;
    offer     = None ;
    mem_offer = None ;
    name      = "" ;
    address   = "" 
  })

let upgrade data ~today ~duration ~seats ~memory ~daily ~offer ~mem_offer ~name ~address = 
  Data.({
    data with 
      seats = seats ;
      memory = memory ;
      first_day = today ;
      last_day = today + duration ;
      daily = daily ;
      offer = offer ;
      mem_offer = mem_offer ;
      name = name ;
      address = address ;
  })
      
let renew data ~today ~duration ~name ~address = 
  let renewed = Data.(
    if data.last_day < today
    then { data with first_day = today ; last_day = today + duration }
    else { data with last_day = data.last_day + duration } )
  in
  Data.({ renewed with 
    name = name ;
    address = address 
  })
	       
let month_offset = [|  0 ;
		       31 ;
		       31 + 28 ;
		       31 + 28 + 31 ;
		       31 + 28 + 31 + 30 ;
		       31 + 28 + 31 + 30 + 31 ;
		       31 + 28 + 31 + 30 + 31 + 30 ;
		       31 + 28 + 31 + 30 + 31 + 30 + 31 ;
		       31 + 28 + 31 + 30 + 31 + 30 + 31 + 31 ;
		       31 + 28 + 31 + 30 + 31 + 30 + 31 + 31 + 30 ;
		       31 + 28 + 31 + 30 + 31 + 30 + 31 + 31 + 30 + 31 ;
		       31 + 28 + 31 + 30 + 31 + 30 + 31 + 31 + 30 + 31 + 30
		   |]

let day_of_time t = 
  let tm = Unix.localtime t in

  let year_offset  = 365 * (tm.Unix.tm_year - (2010 - 1900)) in
  let month_offset = month_offset.(tm.Unix.tm_mon) in
  let day_offset =
    let day = if tm.Unix.tm_mon = 1 && tm.Unix.tm_mday = 29 then 28 else tm.Unix.tm_mday in
    day - 1
  in

  year_offset + month_offset + day_offset

let today () = 
  day_of_time (Unix.gettimeofday ())

let ymd_of_day t = 
  let t = max 0 t in
  let year = 2010 + (t / 365) in
  let month, day, _ =
    List.fold_left
      (fun (month,day,keep) days -> if day >= days && not keep then (month+1, day-days, keep) else (month, day, true)) 
      (0, t mod 365, false)
      [ 31; 28; 31; 30; 31; 30; 31; 31; 30; 31; 30 ]
  in
  year, month+1, day+1

let string_of_day t = 
  let y,m,d = ymd_of_day t in
  Printf.sprintf "%02d/%02d/%d" d m y 

let rebate ?day client = 
  let day = match day with None -> today () | Some day -> day in
  let days  = client.Data.last_day - day in
  if days <= 0 then 0 else
    let (n,d) = client.Data.daily in
    n * days / d 

module ByInstance = CouchDB.DocView(struct
  module Key = IInstance
  module Value = Fmt.Unit
  module Doc = Data
  module Design = Design
  let name = "by_instance"
  let map  = "emit(doc.instance,null)"
end)

let by_instance instance = 
  let instance = IInstance.decay instance in
  let! found = ohm $ ByInstance.doc instance in
  return (match found with
    | []        -> None
    | head :: _ -> Some (IRunOrg.Client.of_id head # id, head # doc))

let create join_time instance =
  let instance = IInstance.decay instance in
  let! client_opt = ohm $ by_instance instance in
  match client_opt with Some _ -> return () | None ->
    let  id  = IRunOrg.Client.gen () in
    let  obj = fresh (day_of_time join_time) instance in
    let! _   = ohm $ MyTable.transaction id (MyTable.insert obj)in
    let! ()  = ohm $ Signals.update_call (id, obj) in
    return ()

let daily_add (n,d) (n',d') = 
  let rec gcd a b = if b = 0 then a else gcd b (a mod b) in
  let g = gcd d d' in
  let m = d / g and m' = d' / g in
  (m * n' + m' * n , m * m' * g)

let refresh ?(force=false) id =
  
  let! old_client = ohm_req_or (return ()) $ MyTable.get id in

  let client = fresh (old_client.Data.joined) (old_client.Data.instance) in  
 
  let! orders = ohm $ MRunOrg_order.by_client id in
  
  let new_client = List.fold_left begin fun client (oid,order) ->
    let today = day_of_time order.O.time in 
    match order.O.kind with 

      | `Renew   r -> (renew client
			 ~today ~duration:(r # days) ~name:order.O.name 
			 ~address:order.O.address)

      | `Upgrade u -> let s = u # seat in
		      upgrade client
			~today
			~duration:(u # days) 
			~seats:(s # seats) 
			~memory:(s # memory + (match u # memory with 
			  | None -> 0
			  | Some m -> m # memory))
			~daily:(match u # memory with
			  | None -> s # daily 
			  | Some m -> daily_add (s # daily) (m # daily))
			~offer:(Some (s # offer))
			~mem_offer:(BatOption.map (fun m -> m # offer) u # memory) 	  
			~name:order.O.name
			~address:order.O.address
			
  end client orders in 

  if force || old_client <> new_client then begin 
    
    let! _  = ohm $ MyTable.transaction id (MyTable.update (fun _ -> new_client)) in
    let! () = ohm $ Signals.update_call (id, new_client) in
    return ()
      
  end else return ()

let _ = 
  Sig.listen MRunOrg_order.Signals.update (fun (_, order) -> refresh (order.O.client))

module Backdoor = struct

  let get cid = MyTable.get cid

  let get_all = 

    let! all = ohm $ ByInstance.doc_query () in

    let list = List.map (fun item ->
      IRunOrg.Client.of_id (item # id) ,
      item # doc
    ) all in

    return list 

end
