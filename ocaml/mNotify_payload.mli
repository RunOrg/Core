(* © 2012 RunOrg *)

include Ohm.Fmt.FMT with type t = 
  [ `NewWallItem   of [`WallReader|`WallAdmin] * IItem.t
  | `NewFavorite   of [`ItemAuthor] * IAvatar.t * IItem.t
  | `NewComment    of [`ItemAuthor|`ItemFollower] * IComment.t
  | `BecomeMember  of IInstance.t * IAvatar.t 
  | `BecomeAdmin   of IInstance.t * IAvatar.t  
  | `EventInvite   of IEvent.t * IAvatar.t
  | `EventRequest  of IEvent.t * IAvatar.t 
  | `GroupRequest  of IEntity.t * IAvatar.t 
  | `NewInstance   of IInstance.t * IAvatar.t 
  | `NewUser       of IUser.t 
  | `NewJoin       of IInstance.t * IAvatar.t 
  | `CanInstall    of IInstance.t
  ]

val instance : t -> IInstance.t option O.run 
    
val author : 'any ICurrentUser.id -> t ->
  [ `RunOrg of IInstance.t option 
  | `Person of (IAvatar.t * IInstance.t)
  | `Event  of (IAvatar.t * IInstance.t * [`View] MEvent.t) 
  | `Entity of (IAvatar.t * IInstance.t * [`View] MEntity.t) ] option O.run 
  
val channel : t -> MNotifyChannel.t


