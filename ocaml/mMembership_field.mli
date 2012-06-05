(* © 2012 RunOrg *)

include Ohm.Fmt.FMT with type t = 
  <
    name  : string ;
    label : TextOrAdlib.t ;
    edit  : MJoinFields.FieldType.t ;
    valid : [ `required ] list ;
  > ;;

val has_stats : t -> bool

