(* © 2012 RunOrg *)

type data = {
  grant     : [ `Admin | `Token ] option ;
  admin_act : bool ;
  user_act  : bool ;
  time      : float ;
  status    : MMembership_status.t ; 
  mustpay   : bool 
}

include Ohm.Fmt.FMT with type t = data

val reflect : 'a -> MMembership_details.t -> data O.run

val default : bool -> data
