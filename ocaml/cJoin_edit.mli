(* © 2012 RunOrg *)

val box :
     ctx:'a CContext.full 
  -> entity:'any MEntity.t
  -> group:[<`Admin|`Write] MGroup.t 
  -> IAvatar.t 
  -> (UrlSegs.entity * 'b) O.box
