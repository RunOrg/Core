(* © 2013 RunOrg *)

include Ohm.Fmt.FMT with type t = <
  group_validation : [`Manual|`None] option ;
  group_read       : [`Viewers|`Registered|`Managers] option ;
> 

val default : t

module Diff : Ohm.Fmt.FMT with type t = 
  [ `Group_Validation of [`Manual|`None]
  | `Group_Read       of [`Viewers|`Registered|`Managers] 
  ]

val apply : Diff.t list -> t -> t

type 'a config = ITemplate.Group.t -> t -> 'a

val group_validation : [`Manual|`None] config
val group_read       : [`Viewers|`Registered|`Managers] config
