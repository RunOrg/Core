(* © 2013 RunOrg *)

type message  = <
  author : IAvatar.t ;
  text   : string 
>

type miniPoll = <
  author : IAvatar.t ;
  text   : string ;
  poll   : [`Read] IPoll.id
>

type mail = <
  author  : IAvatar.t ;
  subject : string ;
  body    : string 
>

type image    = <
  author : IAvatar.t ;
  file   : [`GetImg] IFile.id
>

type doc     = <
  author : IAvatar.t ;
  file   : [`GetDoc] IFile.id ;
  title  : string ;
  ext    : MOldFile.Extension.t ;
  size   : float
>

type payload = [ `Message  of message 
	       | `MiniPoll of miniPoll
	       | `Image    of image
	       | `Doc      of doc 
	       | `Mail     of mail
	       ] 

val author_by_payload : payload -> IAvatar.t option

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
