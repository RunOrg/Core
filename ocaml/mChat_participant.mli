(* © 2013 RunOrg *)

val count : [<`View|`Post] IChat.Room.id -> int O.run

val list :
     ?start:IAvatar.t
  ->  count:int
  ->  [<`View|`Post] IChat.Room.id
  ->  (IAvatar.t list * IAvatar.t option) O.run
  
val participate : IAvatar.t -> IChat.Room.t -> unit O.run
