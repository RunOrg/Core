(* © 2012 RunOrg *)

module Config : Ohm.Fmt.FMT with type t = <
  closed_on : float option ;
  opened_on : float option ;
> ;;

module Question : Ohm.Fmt.FMT with type t = <
  question : Ohm.I18n.text ;
  answers  : Ohm.I18n.text list ;
  multiple : bool 
> 
