(* © 2012 RunOrg *)

val box : ctx:'any CContext.full -> wall:[`Read] MFeed.t -> ('a * 'b) O.box

val all_active : ctx:'any CContext.full -> Ohm.View.html O.run
