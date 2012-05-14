(* © 2012 RunOrg *)

val reaction : 
     ctx:'any CContext.full
  -> group:[< `Admin | `Write ] MGroup.t
  -> (O.Box.reaction -> 'a O.box)
  -> 'a O.box
