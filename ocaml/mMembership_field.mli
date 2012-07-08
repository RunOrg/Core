(* © 2012 RunOrg *)

include Ohm.Fmt.FMT with type t = 
  <
    name  : string ;
    label : TextOrAdlib.t ;
    edit  : MJoinFields.FieldType.t ;
    required : bool 
  > ;;

val has_stats : t -> bool

