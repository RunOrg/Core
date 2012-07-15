(* © 2012 RunOrg *)

include Ohm.Fmt.FMT with type t = 
  [ `Invite  of < who : IAvatar.t >
  | `Admin   of < who : IAvatar.t ; what : bool >
  | `User    of < who : IAvatar.t ; what : bool >
  | `Payment of < who : IAvatar.t ; paid : bool >  
  ]

val apply : 
     t
  -> (    'any
       -> float
       -> MMembership_details.t
       -> MMembership_details.t O.run) O.run

val admin  : 'a IAvatar.id -> bool -> t
val user   : 'a IAvatar.id -> bool -> t
val invite : 'a IAvatar.id -> t 

val relevant_change : MMembership_details.t -> t -> bool
val make : 'a IAvatar.id -> [< `Accept of bool | `Default of bool | `Invite ] -> t
