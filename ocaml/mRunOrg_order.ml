(* © 2012 MRunOrg *)

open Ohm
open Ohm.Util
open Ohm.Universal
open BatPervasives

module SeatOrder = Fmt.Make(struct
  module IOffer = IRunOrg.Offer
  type json t = <
    daily  : (int * int) ;
    offer  : IOffer.t ;
    seats  : int ;
    memory : int  
  >
end)

module MemoryOptionOrder = Fmt.Make(struct
  module IOffer = IRunOrg.Offer
  type json t = <
    daily  : (int * int) ;
    offer : IOffer.t ;
    memory : int 
  > 
end)

module RenewOrder = Fmt.Make(struct
  type json t = <
    days  : int ;
    start : int ;
    seat : SeatOrder.t ;
    memory : MemoryOptionOrder.t option
  >
end)
    
module UpgradeOrder = Fmt.Make(struct
  type json t = <
    days : int ;
    seat : SeatOrder.t ;
    memory : MemoryOptionOrder.t option
  >
end)

let cost_aux u = 
  let (fullcost,fulldays) = u # seat # daily in
  let days = u # days in 
  let seats = (days * fullcost) / fulldays in
  match u # memory with None -> seats | Some memory ->
    let (fullcost,fulldays) = memory # daily in
    seats + (days * fullcost) / fulldays

let cost = function
  | `Renew   r -> cost_aux r
  | `Upgrade u -> cost_aux u

module Data = struct
  module IPayment      = IPayment
  module IInstance     = IInstance
  module IAvatar       = IAvatar
  module IRunOrgClient = IRunOrg.Client
  module Float         = Fmt.Float
  module T = struct
    type json t = {

      time     : Float.t ; (* Used for sorting *)

     ?name     : string = "" ;
     ?address  : string = "" ;

      cost     : int ; (* The base cost of this offer *)
      rebate   : int ; (* The rebate (due to promotional offers and other reasons) *)
      tax      : int ; (* The tax paid on this offer, paid out of (cost - rebate) *)
      total    : int ; (* The actual cost of this offer (= cost - rebate + tax)  *)
      
      kind     : [ `Renew   of RenewOrder.t
	         | `Upgrade of UpgradeOrder.t
		 ] ;

      status   : [ `Preparing (* Client is preparing order. *)
		 | `Correct   (* Everything is fine (or should be) *)
		 | `Canceled  (* Order has been canceled *)
		 | `Abnormal  (* Something went wrong *)
		 ] ;

      ok       : bool ; (* Does this order apply to the client ? *)

      paid     : [ `Yes          (* MPayment received and confirmed *)
		 | `No           (* MPayment failed or not yet received *)
		 | `Pending      (* MPayment should be received soon *)
		 | `Gift
		 ] ;

      user     : IAvatar.t option ;
      client   : IRunOrgClient.t 
    }
  end
  include T
  include Fmt.Extend(T)
end

module Diff = Fmt.Make(struct
  module IPayment = IPayment
  module IAvatar  = IAvatar
  module Float    = Fmt.Float
  type json t = 
    [ `Update  of <
       time    : Float.t ;
      ?name    : string = "" ;
      ?address : string = "" ;
       kind    : [ `Renew of RenewOrder.t | `Upgrade of UpgradeOrder.t ] ;
       rebate  : int 
    >
    | `User    of IAvatar.t
    | `Status  of < ok : bool ; status : [ `Preparing | `Correct | `Canceled | `Abnormal ] >
    | `Payment of [ `Yes | `No | `Pending | `Gift ]
    | `AcceptFree
    ]
end)

let apply_update c data = 
  let kind   = c # kind in 
  let cost   = cost kind in 
  let rebate = c # rebate in
  let tax    = (max 0 (cost - rebate)) * 196 / 1000 in
  if data.Data.status = `Preparing then Data.({
    data with 
      time    = c # time ;
      name    = c # name ;
      address = c # address ;
      kind    = kind ;
      cost    = cost ;
      rebate  = rebate ;
      tax     = tax ;
      total   = (max 0 (cost - rebate)) + tax ;
  }) else data

let apply_payment p data = 
  Data.({ data with
    paid   = p ;
    ok     = data.ok || (p <> `No) ;
    status =
      if data.status = `Preparing then
	if p = `No then `Preparing else `Correct
      else data.status
  })

let apply_accept_free data = 
  if data.Data.total > 0 || data.Data.status <> `Preparing then data else
    Data.({ data with 
      paid   = `Yes ;
      ok     = true ;
      status = `Correct
    })   

let apply_status s data =
  Data.({ data with ok = s # ok ; status = s # status })

module OrderConfig = struct
  let name = "runorg-order"
  module DataDB    = CouchDB.Convenience.Config(struct let db = O.db "runorg-order" end)
  module VersionDB = CouchDB.Convenience.Config(struct let db = O.db "runorg-order-v" end)
  module Id = IRunOrg.Order
  module Data = Data
  module Diff = Diff 

  let apply = function
    | `Update   c -> return (fun id t data -> return (apply_update c data))
    | `User     u -> return (fun id t data -> return { data with Data.user = Some u })
    | `Status   s -> return (fun id t data -> return (apply_status s data))
    | `Payment  p -> return (fun id t data -> return (apply_payment p data))
    | `AcceptFree -> return (fun id t data -> return (apply_accept_free data))

  module VersionData = Fmt.Make(struct
    module IAvatar = IAvatar
    module IUser = IUser
    type json t = <
      who : [ `auto | `user of IAvatar.t | `admin of IUser.t ]
    >
  end)

  module ReflectedData = Fmt.Unit
  let reflect _ _ = return ()
end

module Store = OhmCouchVersioned.Make(OrderConfig) 

module Signals = struct

  let update_call, update = Sig.make (Run.list_iter identity)
  let _ = Sig.listen Store.Signals.update (fun t -> update_call (Store.id t, Store.current t))

end

module Design = struct
  module Database = Store.DataDB
  let name = "order"
end

module ByClient = CouchDB.DocView(struct
  module Key = IRunOrg.Client
  module Value = Fmt.Unit
  module Doc = Store.Raw
  module Design = Design
  let name = "by_client"
  let map = "if (doc.c.ok) emit(doc.c.client,null)"
end)

let by_client client = 
  let! found = ohm $ ByClient.doc client in
  let orders = 
    List.map (fun item ->
      IRunOrg.Order.Assert.edit (IRunOrg.Order.of_id (item # id)),
      item # doc # current
    ) found
  in
  (* Always in ascending order *)
  let sorted = List.sort (fun (_,a) (_,b) -> compare (a.Data.time) (b.Data.time)) orders in
  return sorted  

let prepare id ~user ~client ~name ~address ~kind ~rebate ~time = 

  let id = IRunOrg.Order.decay id in 

  let cost = cost kind in 
  let tax  = (max 0 (cost - rebate)) * 196 / 1000 in

  let init = Data.({
    time     = time ;
    cost     = cost ;
    rebate   = rebate ;
    tax      = tax ;
    name     = clip 80 name ;
    address  = clip 300 address ;
    total    = (max 0 (cost - rebate)) + tax ;
    kind     = kind ;
    status   = `Preparing ;
    ok       = false;
    paid     = `No ;
    user     = Some (IAvatar.decay user) ;
    client   = client 
  }) in

  let info = object
    method who = `user (IAvatar.decay user)
  end in

  let! _ = ohm $ Store.create ~id ~init ~diffs:[] ~info () in
  return ()

let update id ~user ~name ~address ~kind ~rebate ~time = 

  let id = IRunOrg.Order.decay id in

  let info = object
    method who = `user (IAvatar.decay user)
  end in
  
  let! _ = ohm $ Store.update
    ~id
    ~diffs:[
      `Update (object
	method time    = time
	method name    = clip 80 name
	method address = clip 300 address
	method kind    = kind 
	method rebate  = rebate
      end) ;
      `User (IAvatar.decay user)
    ]
    ~info ()
  in

  return ()

let give ~admin ~name ~address ~client ~kind ~time =

  let id = IRunOrg.Order.gen () in

  let cost = cost kind in 

  let init = Data.({
    time     = time ;
    cost     = cost ;
    rebate   = cost ;
    tax      = 0    ;
    name     = clip 80 name ;
    address  = clip 200 address ;
    total    = 0 ;
    kind     = kind ;
    status   = `Correct ;
    ok       = true ;
    paid     = `Gift ;
    user     = None;
    client   = client 
  }) in

  let info = object
    method who = `admin admin 
  end in

  let! _ = ohm $ Store.create ~id ~init ~diffs:[] ~info () in
  return ()

let accept_free id ~user = 
  
  let id = IRunOrg.Order.decay id in 
  let info = object
    method who = `user (IAvatar.decay user) 
  end in 

  let! _ = ohm $ Store.update
    ~id
    ~diffs:[
      `AcceptFree ;
      `User (IAvatar.decay user) 
    ] 
    ~info ()
  in
    
  return () 
  
let get id = 
  let! t = ohm_req_or (return None) $ Store.get (IRunOrg.Order.decay id) in
  return $ Some (Store.current t)

let payment_update id payment = 
  
  let info = object
    method who = `auto
  end in 

  let! _ = ohm $ Store.update
    ~id
    ~diffs:[`Payment (OhmCouchPaypal.summary (MPayment.status payment))]
    ~info ()
  in

  return ()

let () = 
  Sig.listen MPayment.Signals.update begin fun (_,payment) ->
    match MPayment.reason payment with 
      | `Order id -> payment_update id payment 
  end
