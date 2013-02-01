(* © 2013 RunOrg *)

include HEntity.SET with type 'a can = 'a MDiscussion_can.t and type diff = MDiscussion_core.diff

val edit : title:string -> body:MRich.OrText.t -> ('a,#O.ctx) t
