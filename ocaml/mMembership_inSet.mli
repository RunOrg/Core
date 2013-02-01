(* © 2013 RunOrg *)
  
val all :
     [<`Admin|`Write|`List|`Bot] IAvatarSet.id
  -> MAccess.State.t 
  -> (bool * IAvatar.t) list O.run
    
val list_members :
     ?start:Ohm.Id.t
  -> count:int
  -> [<`Admin|`Write|`List|`Bot] IAvatarSet.id 
  -> (IAvatar.t list * Ohm.Id.t option) O.run

val list_everyone :
     ?start:Ohm.Id.t
  -> count:int
  -> [<`Admin|`Write|`List|`Bot] IAvatarSet.id 
  -> (IAvatar.t list * Ohm.Id.t option) O.run

val avatars : 
     [<`Admin|`Write|`List|`Bot] IAvatarSet.id
  -> start:IAvatar.t option
  -> count:int
  -> (IAvatar.t list * IAvatar.t option) O.run
  
val count : 'any IAvatarSet.id -> < count : int ; pending : int ; any : int > O.run
