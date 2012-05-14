(* © 2012 RunOrg *)

open MVote_common
  
type t = <
  count   : int ;
  votes   : (Ohm.I18n.text * int) list 
>

val get_short : [<`Read|`Vote|`Admin] vote -> t O.run 
val get_long  : [<`Read|`Vote|`Admin] vote -> (IAvatar.t * int list) list O.run 
  
