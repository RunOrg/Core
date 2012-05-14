(* © 2012 RunOrg *)

module Reason : Ohm.Fmt.FMT with type t = 
  [ `Order of IRunOrg.Order.t ]

type t 

val get : 'any IPayment.id -> t option O.run
val reason : t -> Reason.t
val amount : t -> int
val status : t -> OhmCouchPaypal.Status.t option

val start_transaction : 
     amount:int
  -> tax:int
  -> invoice:string
  -> returnurl:(IPayment.t -> string)
  -> cancelurl:(IPayment.t -> string)
  -> reason:Reason.t
  -> string option O.run

val is_payable : IPayment.t -> [ `Failed
				| `Paid of t 
				| `Payable of t * ([`Exec] IPayment.id) ] O.run

val finish_transaction : [`Exec] IPayment.id -> OhmCouchPaypal.Status.t option O.run

module Signals : sig
  val update : (IPayment.t * t, unit O.run) Ohm.Sig.channel
end
