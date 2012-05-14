(* © 2012 MRunOrg *)

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
