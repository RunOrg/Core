(* © 2012 RunOrg *) 

include OhmCouchExport.EXPORT with type piece = string list
			      and  type whole = string
			      and  type id    = IExport.t 

val create : ?size:int -> unit -> [`Read] IExport.id O.run
val download : [`Read] IExport.id -> string option O.run
val state : unit
