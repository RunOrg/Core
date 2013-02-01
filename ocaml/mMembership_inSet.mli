(* © 2013 RunOrg *)
      
val list_members :
     ?start:IAvatar.t
  -> count:int
  -> [<`Admin|`Write|`List|`Bot] IAvatarSet.id 
  -> (IAvatar.t list * IAvatar.t option) O.run

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
