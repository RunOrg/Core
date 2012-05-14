(* © 2012 RunOrg *)

val link_box : 
     ctx:[`IsToken] CContext.full
  -> entity:[<`Admin|`View] MEntity.t
  -> group:[`Admin] MGroup.t
  -> 'c O.box
