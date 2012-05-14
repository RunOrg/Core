(* © 2012 RunOrg *)

open MVote_common 

type t = <
  question : Ohm.I18n.text ;
  answers  : Ohm.I18n.text list ;
  multiple : bool 
> 

val create : 
     multiple:bool
  -> question:Ohm.I18n.text
  -> answers:Ohm.I18n.text list
  -> t 

val get : 'any vote -> t 

