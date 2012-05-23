(* © 2012 IRunOrg *)

type 'relation id
  
val user : 'relation id -> [`Old] ICurrentUser.id
val instance : 'relation id -> 'relation IInstance.id
val role : 'relation id -> [`Admin|`Token|`Contact|`Nobody]
val avatar : 'relation id -> [`IsSelf] IAvatar.id option
  
module Assert : sig
  val make :
    role:[`Admin|`Token|`Contact|`Nobody]
    -> id:[`IsSelf] IAvatar.id option
    -> ins:'any IInstance.id 
    -> usr:[`Old] ICurrentUser.id
    -> 'any id
end
  
module Deduce : sig

  val is_anyone    : 'any id -> [`Unknown]   id  
  val is_admin     : 'any id -> [`IsAdmin]   id option
  val is_token     : 'any id -> [`IsToken]   id option 
  val is_contact   : 'any id -> [`IsContact] id option
    
end


