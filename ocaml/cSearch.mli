(* © 2013 RunOrg *)

module AvatarOrGroup : Ohm.Fmt.FMT with type t = [ `Avatar of IAvatar.t | `Group of IGroup.t ]

val target_picker : ?query:bool -> [`IsToken] CAccess.t -> 
  (#O.ctx as 'ctx, 
      ?left:bool 
   -> label:('ctx,string) Ohm.Run.t
   -> ?max:int
   -> ('seed -> ('ctx, AvatarOrGroup.t list) Ohm.Run.t)
   -> (OhmForm.field
       -> AvatarOrGroup.t list
       -> ('ctx, ('result, OhmForm.field * string) BatPervasives.result) Ohm.Run.t)
   -> ('ctx, 'seed, 'result) OhmForm.template
  ) Ohm.Run.t
