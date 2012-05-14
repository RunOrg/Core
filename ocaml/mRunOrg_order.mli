(* © 2012 MRunOrg *)

module SeatOrder : Ohm.Fmt.FMT with type t = <
  daily  : (int * int) ;
  seats  : int ;
  offer  : IRunOrg.Offer.t ;
  memory : int 
>

module MemoryOptionOrder : Ohm.Fmt.FMT with type t = <
  daily  : (int * int) ;
  offer  : IRunOrg.Offer.t ;
  memory : int 
> 
    
module UpgradeOrder : Ohm.Fmt.FMT with type t = <
  days : int ;
  seat : SeatOrder.t ;
  memory : MemoryOptionOrder.t option
>

module RenewOrder : Ohm.Fmt.FMT with type t = <
  days  : int ;
  start : int ;
  seat : SeatOrder.t ;
  memory : MemoryOptionOrder.t option
>

module Data : sig
  type t = {

    time     : float ; (* Execution time *)
    
    name     : string ;
    address  : string ;

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
	       | `No           (* MPayment failed *)
	       | `Pending      (* MPayment should be received soon *)
	       | `Gift
	       ] ;
    
    user     : IAvatar.t option ;
    client   : IRunOrg.Client.t 
  }
end

module Signals : sig
  val update : (IRunOrg.Order.t * Data.t, unit O.run) Ohm.Sig.channel
end

val prepare :
     [`Edit] IRunOrg.Order.id
  -> user    : [`IsSelf] IAvatar.id 
  -> client  : IRunOrg.Client.t
  -> name    : string 
  -> address : string
  -> kind    : [ `Renew of RenewOrder.t | `Upgrade of UpgradeOrder.t ]
  -> rebate  : int
  -> time    : float
  -> unit O.run

val update : 
     [`Edit] IRunOrg.Order.id
  -> user    : [`IsSelf] IAvatar.id
  -> name    : string
  -> address : string
  -> kind    : [ `Renew of RenewOrder.t | `Upgrade of UpgradeOrder.t ]
  -> rebate  : int
  -> time    : float
  -> unit O.run

val give :
     admin : IUser.t 
  -> name : string
  -> address : string
  -> client : IRunOrg.Client.t
  -> kind : [ `Renew of RenewOrder.t | `Upgrade of UpgradeOrder.t ]
  -> time : float
  -> unit O.run

val accept_free :
     [`Edit] IRunOrg.Order.id
  -> user : [`IsSelf] IAvatar.id
  -> unit O.run
   
val get : 'any IRunOrg.Order.id -> Data.t option O.run

val by_client : IRunOrg.Client.t -> ([`Edit] IRunOrg.Order.id * Data.t) list O.run
