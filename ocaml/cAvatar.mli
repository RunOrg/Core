(* © 2012 RunOrg *)

type details = <
  url     : string ;
  name    : string ;
  picture : string ;
  status  : VStatus.t
>

val extract_one : Ohm.I18n.t -> 'a CContext.full -> 'b IAvatar.id -> details O.run

val extract : Ohm.I18n.t -> 'a CContext.full -> 'b IAvatar.id list -> details list O.run

val extract_map : 
     Ohm.I18n.t
  -> 'a CContext.full
  -> ('b -> 'c IAvatar.id)
  -> 'b list
  -> ('b * details) list O.run
