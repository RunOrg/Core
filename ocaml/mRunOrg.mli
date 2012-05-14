(* © 2012 RunOrg *)

module Order : sig

  module SeatOrder : Ohm.Fmt.FMT with type t = <
    daily  : (int * int) ;
    seats  : int ;
    memory : int ; 
    offer  : IRunOrg.Offer.t 
  >

  module MemoryOptionOrder : Ohm.Fmt.FMT with type t = <
    daily  : (int * int) ;
    memory : int ;
    offer  : IRunOrg.Offer.t 
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
      
      time     : float ; (* Day number *)
      
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
    -> user   : [`IsSelf] IAvatar.id 
    -> client : IRunOrg.Client.t
    -> name    : string
    -> address : string
    -> kind   : [ `Renew of RenewOrder.t | `Upgrade of UpgradeOrder.t ]
    -> rebate : int
    -> time   : float
    -> unit O.run

  val update : 
       [`Edit] IRunOrg.Order.id
    -> user : [`IsSelf] IAvatar.id
    -> name    : string
    -> address : string
    -> kind   : [ `Renew of RenewOrder.t | `Upgrade of UpgradeOrder.t ]
    -> rebate : int
    -> time   : float
    -> unit O.run

  val give :
       admin : IUser.t 
    -> name    : string
    -> address : string
    -> client : IRunOrg.Client.t
    -> kind : [ `Renew of RenewOrder.t | `Upgrade of UpgradeOrder.t ]
    -> time : float
    -> unit O.run

  val accept_free :
       [`Edit] IRunOrg.Order.id
    -> user : [`IsSelf] IAvatar.id
    -> unit O.run   
    
  val get :'any IRunOrg.Order.id -> Data.t option O.run
    
  val by_client : IRunOrg.Client.t -> ([`Edit] IRunOrg.Order.id * Data.t) list O.run

end

module Client : sig

  module Data : sig
    type t = {
      seats     : int ;
      memory    : int ;
      first_day : int ;
      last_day  : int ;
      daily     : (int * int) ;
      joined    : int ;
      instance  : IInstance.t ;
      offer     : IRunOrg.Offer.t option ;
      mem_offer : IRunOrg.Offer.t option ;
      name      : string ;
      address   : string
    }
  end
 
  module Signals : sig
    val update : (IRunOrg.Client.t * Data.t, unit O.run) Ohm.Sig.channel
  end

  val today : unit -> int
    
  val day_of_time : float -> int

  val ymd_of_day : int -> int * int * int
    
  val string_of_day : int -> string

  val rebate : ?day:int -> Data.t -> int
    
  val by_instance : 'any IInstance.id -> (IRunOrg.Client.t * Data.t) option O.run
    
  val create : float -> [`Created] IInstance.id -> unit O.run

  module Backdoor : sig

    val get : IRunOrg.Client.t -> Data.t option O.run      
    val get_all : (IRunOrg.Client.t * Data.t) list O.run
      
  end

end

module Offer: sig
    
  type main = < 
    label : [`label of string | `text of string] ;
    seats : int ; 
    memory : int ; 
    daily : (int * int) ;
    days : int
  > ;;

  type memory = < label : [`label of string | `text of string] ; memory : int ; daily : (int*int) > ;;
  
  val main : ([`Main] IRunOrg.Offer.id * main) list
    
  val memory : ([`Memory] IRunOrg.Offer.id * memory) list 

  val print_year_price : int * int -> string
  val print_memory : int -> string

  val check :
       ('a IRunOrg.Offer.id * 'b) list
    -> IRunOrg.Offer.t
    -> ('a IRunOrg.Offer.id * 'b) option

  val check_opt :
       ('a IRunOrg.Offer.id * 'b) list
    -> IRunOrg.Offer.t option
    -> ('a IRunOrg.Offer.id * 'b) option option

end
