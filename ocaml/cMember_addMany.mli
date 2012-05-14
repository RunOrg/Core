(* © 2012 RunOrg *)

val reaction : 
     ctx:[`IsToken] CContext.full
  -> group:[<`Write|`Admin] MGroup.t
  -> (O.Box.reaction -> 'a O.Box.t)
  -> 'a O.Box.t


