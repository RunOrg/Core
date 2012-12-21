(* © 2012 RunOrg *)

include Ohm.Fmt.FMT with type t = <
  group_validation : [`Manual|`None] option ;
  group_read       : [`Viewers|`Registered|`Managers] option ;
  collab_read      : [`Viewers|`Registered|`Managers] option ;
  collab_write     : [`Viewers|`Registered|`Managers] option 
> 

val default : t

module Diff : Ohm.Fmt.FMT with type t = 
  [ `Group_Validation of [`Manual|`None]
  | `Group_Read       of [`Viewers|`Registered|`Managers] 
  | `Collab_Read      of [`Viewers|`Registered|`Managers] 
  | `Collab_Write     of [`Viewers|`Registered|`Managers] 
  ]

val apply : Diff.t list -> t -> t

type 'a config = ITemplate.Event.t -> t -> 'a

val group_validation : [`Manual|`None] config
val group_read       : [`Viewers|`Registered|`Managers] config
val collab_read      : [`Viewers|`Registered|`Managers] config
val collab_write     : [`Viewers|`Registered|`Managers] config
