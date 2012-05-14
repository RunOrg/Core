(* © 2012 RunOrg *)

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

val item_of_data : 'any IItem.id -> ?self:[`IsSelf] IAvatar.id -> MItem_data.t -> item

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

val bot_item_of_data : 'any IItem.id -> MItem_data.t -> bot_item
