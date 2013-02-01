(* © 2013 RunOrg *)

type 'role t 

val contact : 'any t -> [`IsContact] t
val member  : 'any t -> [`IsToken] t option
val admin   : 'any t -> [`IsAdmin] t option
  
val avatar   : 'any t -> [`IsSelf] IAvatar.id 
val instance : 'any t -> 'any IInstance.id
val user     : 'any t -> [`Old] ICurrentUser.id

(* Only the "MAvatar" module should be allowed to call these functions. *)
module Make : sig

  val contact :
       role: [`Token|`Admin|`Contact] 
    -> aid:'a IAvatar.id
    -> iid:'b IInstance.id
    -> uid:[`Old] ICurrentUser.id
    -> [`IsContact] t

end
