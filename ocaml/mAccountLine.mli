(* © 2013 RunOrg *)

module Method : Ohm.Fmt.FMT with type t = 
  [ `Cash 
  | `Transfer
  | `AutoBill
  | `Card
  | `Paypal
  | `Cheque
  | `Other ]

val all_methods : Method.t list 

module Data : sig
  type t = {
    join      : bool ;
    what      : Ohm.I18n.text ;
    mode      : Method.t ;
    subscribe : bool ;
    reference : string option ;
    canceled  : (IAvatar.t option * float) option ;
    amount    : int ;
    payer     : IAvatar.t option ;
    creator   : IAvatar.t option ;
    comment   : string ;
    created   : float ;
    paid      : string ;
    instance  : IInstance.t ;
    entity    : IEntity.t option ;
    direction : [`In|`Out]
  }
end

type where = 
    [ `Instance of [`IsAdmin] IInstance.id
    | `Entity of [`Admin] IEntity.id * IInstance.t 
    ]

val create : 
  what:Ohm.I18n.text ->
  subscribe:bool ->
  join:bool ->
  where:where ->
  mode:Method.t ->
  direction:[`In|`Out] ->
  amount:int ->
  time:string ->
  payer:IAvatar.t option ->
  creator:[`IsSelf] IAvatar.id option ->
  reference:string option ->
  comment:string ->
  ([`View] IAccountLine.id * Data.t) O.run

val update : 
  where ->
  IAccountLine.t ->
  who:[`IsSelf] IAvatar.id option ->
  what:Ohm.I18n.text ->
  reference:string option ->
  comment:string ->
  unit O.run

val cancel : 
  where ->
  IAccountLine.t ->
  [`IsSelf] IAvatar.id option ->
  unit O.run

val totals : where -> < total_in : int ; total_out : int > O.run
    
val get : [`View] IAccountLine.id -> Data.t option O.run

val try_get : where -> IAccountLine.t -> ([`View] IAccountLine.id * Data.t) option O.run

val get_all : where -> ([`View] IAccountLine.id * Data.t) list O.run
  
