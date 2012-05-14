(* © 2012 RunOrg *)

val access : unit -> MAccess.in_group
  
val all :
     [<`Admin|`Write|`List|`Bot] IGroup.id
  -> MAccess.State.t 
  -> (bool * IAvatar.t) list O.run
    
val list_members :
     ?start:Ohm.Id.t
  -> count:int
  -> [<`Admin|`Write|`List|`Bot] IGroup.id 
  -> (IAvatar.t list * Ohm.Id.t option) O.run

val list_everyone :
     ?start:Ohm.Id.t
  -> count:int
  -> [<`Admin|`Write|`List|`Bot] IGroup.id 
  -> (IAvatar.t list * Ohm.Id.t option) O.run

val avatars : 
     [<`Admin|`Write|`List|`Bot] IGroup.id
  -> start:IAvatar.t option
  -> count:int
  -> (IAvatar.t list * IAvatar.t option) O.run
  
val count : 'any IGroup.id -> < count : int ; pending : int > O.run
