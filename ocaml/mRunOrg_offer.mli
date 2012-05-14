(* © 2012 MRunOrg *)

type main = < 
  label : Ohm.I18n.text ; 
  seats : int ; 
  memory : int ; 
  daily : (int * int) ; 
  days : int 
> ;;

type memory = < label : Ohm.I18n.text ; memory : int ; daily : (int*int) > ;;

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
