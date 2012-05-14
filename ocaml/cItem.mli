(* © 2012 RunOrg *)

val url : 'any CContext.full -> 'a IItem.id -> string option O.run

module Attach : sig

  val poll : 'any CContext.full -> [`Read] IPoll.id -> Ohm.View.html O.run

end

type config = <
  react : bool ;
  chat  : [`View] IChat.Room.id option -> string option 
>

val liked : 
     [ `IsSelf ] IAvatar.id
  -> MItem.item
  -> bool O.run

val reply :
     'any CContext.full 
  -> [`Read] IComment.id
  -> VWall.reply option O.run

val renderer : 
     from:[ `feed   of [`Admin] IFeed.id 
	  | `album  of [`Admin] IAlbum.id 
	  | `folder of [`Admin] IFolder.id ] option
  -> config:config
  -> ctx:'a CContext.full 
  -> MItem.item
  -> Ohm.View.html O.run

val display : 
     ctx:'a CContext.full
  -> from:[ `feed   of [`Admin] IFeed.id 
	  | `album  of [`Admin] IAlbum.id 
	  | `folder of [`Admin] IFolder.id ] option
  -> config:config
  -> item:MItem.item
  -> Ohm.View.html O.run
