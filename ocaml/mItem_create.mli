(* © 2012 RunOrg *)

val poll : 
     [`IsSelf] IAvatar.id 
  -> string
  -> [`Created] IPoll.id 
  -> IInstance.t
  -> [`Write] IFeed.id
  -> [`Created] IItem.id O.run

val message : 
     [`IsSelf] IAvatar.id 
  -> string 
  -> IInstance.t
  -> [`Write] IFeed.id
  -> [`Created] IItem.id O.run

val mail : 
     [`IsSelf] IAvatar.id 
  -> subject:string
  -> string
  -> IInstance.t
  -> [`Admin] IFeed.id
  -> [`Created] IItem.id O.run

val chat_request : 
     [`IsSelf] IAvatar.id 
  -> string
  -> 'any IInstance.id
  -> [`Write] IFeed.id
  -> [`Created] IItem.id O.run

val image :
     'any # MAccess.context 
  -> [`Write] MAlbum.t
  -> ([`Created] IItem.id * [`PutImg] IFile.id) option O.run

val doc :
     'any # MAccess.context 
  -> [`Write] MFolder.t
  -> ([`Created] IItem.id * [`PutDoc] IFile.id) option O.run
