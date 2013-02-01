(* © 2013 RunOrg *)

val with_pictures : 
     count:int
  -> [`ViewContacts] IInstance.id
  -> IAvatar.t list O.run
  
val all_members : [`Bot] IInstance.id -> IAvatar.t list O.run
