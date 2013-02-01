(* © 2013 RunOrg *)

val admin : 
     from:'any MActor.t
  -> [<`Admin|`Write|`Bot] IAvatarSet.id
  -> 'a IAvatar.id list
  -> [ `Accept of bool | `Invite | `Default of bool ] list
  -> unit O.run
    
val create : 
     from:'any MActor.t
  -> 'a IInstance.id 
  -> [<`Admin|`Write|`Bot] IAvatarSet.id
  -> ( string * string * string ) list
  -> [ `Accept of bool | `Invite | `Default of bool ] list
  -> unit O.run
