(* © 2012 RunOrg *)

include Ohm.Fmt.FMT with type t = 
  <
    name  : string ;
    label : [`label of string | `text of string] ;
    edit  :  MJoinFields.FieldType.t ;
    valid : [ `required | `max of int ] list ;
  > ;;

val has_stats : t -> bool

