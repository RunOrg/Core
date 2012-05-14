(* © 2012 RunOrg *)

module Format : Ohm.Fmt.FMT with type t = [ `Viewers | `Registered | `Managers ]

val viewers    : 'any MEntity_can.t -> MAccess.t
val registered : 'any MEntity_can.t -> MAccess.t
val managers   : 'any MEntity_can.t -> MAccess.t

val make       :
     'any MEntity_can.t 
  -> [< `Viewers | `Registered | `Managers ]
  -> MAccess.t
  
val which      : MAccess.t -> [> `Viewers | `Registered | `Managers ] 
    
