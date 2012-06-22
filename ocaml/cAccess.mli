(* © 2012 RunOrg *)

class type ['level] t = object
  method self             : [`IsSelf] IAvatar.id
  method isin             : 'level IIsIn.id 
  method instance         : MInstance.t
  method iid              : 'level IInstance.id 
end

val make : 
     [`Old] ICurrentUser.id
  -> 'any IInstance.id
  -> MInstance.t
  -> [`IsToken] t option O.run

val admin : 'any t -> [`IsAdmin] t option
