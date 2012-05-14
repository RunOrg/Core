(* © 2012 RunOrg *)

val edit : ctx:[`IsAdmin] CContext.full -> (O.Box.reaction -> 'b O.box) -> 'b O.box
