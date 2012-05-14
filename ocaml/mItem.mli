(* © 2012 RunOrg *)

type 'a source = 
  [ `feed   of 'a IFeed.id 
  | `album  of 'a IAlbum.id
  | `folder of 'a IFolder.id ]

type message  = <
  author : IAvatar.t ;
  text   : string 
>

type miniPoll = <
  author : IAvatar.t ;
  text   : string ;
  poll   : [`Read] IPoll.id
>

type image    = <
  author : IAvatar.t ;
  file   : [`GetImg] IFile.id
>

type doc     = <
  author : IAvatar.t ;
  file   : [`GetDoc] IFile.id ;
  title  : string ;
  ext    : MFile.Extension.t ;
  size   : float
>

type chat    = <
  room   : [`View] IChat.Room.id
>

type chat_request = <
  author : IAvatar.t ;
  topic  : string
>

type payload = [ `Message  of message 
	       | `MiniPoll of miniPoll
	       | `Image    of image
	       | `Doc      of doc 
	       | `Chat     of chat
	       | `ChatReq  of chat_request ] 

val author : payload -> IAvatar.t option

type item = < 
  where   : [`Unknown] MItem_common.source ; 
  own     : [`Own]  IItem.id option ;
  id      : [`Read] IItem.id ;  
  time    : float ;
  payload : payload ;
  clike   : IAvatar.t list ;
  nlike   : int ;
  ccomm   : [`Read] IComment.id list ;
  ncomm   : int ;
  iid     : IInstance.t 
> 

type bot_item = < 
  where   : [`Unknown] MItem_common.source ; 
  id      : [`Bot] IItem.id ;  
  time    : float ;
  payload : payload ;
  clike   : IAvatar.t list ;
  nlike   : int ;
  ccomm   : [`Read] IComment.id list ;
  ncomm   : int ;
  iid     : IInstance.t 
> 

module Signals : sig    
  val on_post       : (bot_item, unit O.run) Ohm.Sig.channel
  val on_obliterate : (IItem.t, unit O.run) Ohm.Sig.channel
end

module Create : sig

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

end

module Remove : sig
  val delete   : [`Remove] IItem.id -> unit O.run
  val moderate : IItem.t -> [`Admin] source -> unit O.run
end

val last :
     ?self:[`IsSelf] IAvatar.id
  -> [`Read] source
  -> item option O.run

val list : 
     ?self:[`IsSelf] IAvatar.id 
  -> [`Read] source
  -> count:int
  -> float option
  -> (item list * float option) O.run

val prev_next : item -> (IItem.t option * IItem.t option) O.run

val exists : [`Read] source -> bool O.run

val try_get : 
  'any # MAccess.context -> 'a IItem.id -> item option O.run

val interested : [`Bot] IItem.id -> IAvatar.t list O.run

module Backdoor : sig

  val count : unit -> int O.run

  val get : 'a IItem.id -> bot_item option O.run

end
