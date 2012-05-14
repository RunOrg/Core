(* © 2012 RunOrg *)

val box : 
     ctx:[`IsToken] CContext.full
  -> entity:[< `Admin|`View]  MEntity.t
  -> group:[<`Admin|`Write] MGroup.t
  -> UrlSegs.entity O.box
