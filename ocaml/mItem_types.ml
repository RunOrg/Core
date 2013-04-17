(* © 2012 RunOrg *)

open MItem_common

module Data = MItem_data 

(* Type definitions ------------------------------------------------------------------------ *)

type message  = MItem_payload.Message.t

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

let author_by_payload = function 
  | `Message  m -> Some (m # author) 
  | `MiniPoll p -> Some (p # author) 
  | `Image    i -> Some (i # author) 
  | `Doc      d -> Some (d # author) 
  | `Mail     m -> Some (m # author) 

type item = < 
  where   : [`Unknown] source ; 
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

(* Type conversions ------------------------------------------------------------------------ *)

(* Comments can always be seen if the item is visible ... *)
let comments t = 
  List.map IComment.Assert.read (t # ccomm) 

(* Mark contents as visible, because we are looking at the
   container item. *)
let payload  t = match t # payload with 
  | `Message  m -> `Message m
  | `Mail     m -> `Mail m 
  | `MiniPoll p -> let id = IPoll.Assert.read (p # poll) in
		   `MiniPoll ( object
		     method author = p # author
		     method text   = p # text
		     method poll   = id
		   end )
  | `Image    i -> let id = IFile.Assert.get_img (i # file) in
		   `Image ( object
		     method author = i # author
		     method file   = id
		   end )
  | `Doc      d -> let id = IFile.Assert.get_doc (d # file) in
		   `Doc ( object
		     method author = d # author
		     method title  = d # title
		     method ext    = d # ext
		     method size   = d # size
		     method file   = id
		   end )
		    
let item_of_data itid ?self (t:Data.t) = 

  let own = match self with None -> None | Some aid -> 
    if Some (IAvatar.decay aid) = Data.author t then Some (IItem.Assert.own itid) else None
  in

  ( object
    method where   = t # where
    method time    = t # time
    method clike   = t # clike
    method nlike   = t # nlike
    method ccomm   = comments t
    method ncomm   = t # ncomm
    method payload = payload  t
    method iid     = t # iid
    method id      = IItem.Assert.read itid
    method own     = own 
    end )

let bot_item_of_data itid (t:Data.t) = 

  ( object
    method where   = t # where
    method time    = t # time
    method clike   = t # clike
    method nlike   = t # nlike
    method ccomm   = comments t
    method ncomm   = t # ncomm
    method payload = payload  t
    method iid     = t # iid
    method id      = IItem.Assert.bot itid
    end )
