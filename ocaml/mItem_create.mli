(* © 2013 RunOrg *)

val poll : 
     'any MActor.t
  -> string
  -> [`Created] IPoll.id 
  -> IInstance.t
  -> [`Write] IFeed.id
  -> [`Created] IItem.id O.run

val message : 
     'any MActor.t
  -> string 
  -> IInstance.t
  -> [`Write] IFeed.id
  -> [`Created] IItem.id O.run

val mail : 
     'any MActor.t
  -> subject:string
  -> string
  -> IInstance.t
  -> [`Admin] IFeed.id
  -> [`Created] IItem.id O.run

val image :
     'any MActor.t
  -> [`Write] MAlbum.t
  -> ([`Created] IItem.id * [`PutImg] IFile.id) option O.run

val doc :
     'any MActor.t
  -> [`Write] MFolder.t
  -> ([`Created] IItem.id * [`PutDoc] IFile.id) option O.run
