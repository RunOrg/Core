(* © 2012 RunOrg *) 

include OhmCouchExport.EXPORT with type piece = string list
			      and  type whole = string
			      and  type id    = IExport.t 

val download : [`Read] IExport.id -> string option O.run
val state : unit
