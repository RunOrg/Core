(* © 2012 RunOrg *)

val root_box : 
     ctx:'a CContext.full
  -> group:[< `Admin | `List | `Write ] MGroup.t
  -> 'b O.box
