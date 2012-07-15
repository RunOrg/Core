(* © 2012 RunOrg *)

val admin : 
     from:[`IsSelf] IAvatar.id
  -> [<`Admin|`Write|`Bot] IGroup.id
  -> 'a IAvatar.id list
  -> [ `Accept of bool | `Invite | `Default of bool ] list
  -> unit O.run
    
val create : 
     from:[`IsSelf] IAvatar.id
  -> 'a IInstance.id 
  -> [<`Admin|`Write|`Bot] IGroup.id
  -> ( string * string * string ) list
  -> [ `Accept of bool | `Invite | `Default of bool ] list
  -> unit O.run
