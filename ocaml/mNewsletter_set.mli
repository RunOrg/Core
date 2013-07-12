(* © 2013 RunOrg *)

include HEntity.SET with type 'a can = 'a MNewsletter_can.t and type diff = MNewsletter_core.diff

val edit : title:string -> body:MRich.OrText.t -> ('a,#O.ctx) t

val send : [`Admin] IGroup.id list -> ('a,#O.ctx) t
