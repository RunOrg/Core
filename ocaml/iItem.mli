(* © 2012 IRunOrg *)

include Ohm.Id.PHANTOM
  
module Assert : sig
  val own     : 'any id -> [`Own] id 
  val created : 'any id -> [`Created] id
  val read    : 'any id -> [`Read] id
  val replied : 'any id -> [`Replied] id
  val liked   : 'any id -> [`Liked] id
  val remove  : 'any id -> [`Remove] id
  val bot     : 'any id -> [`Bot] id
end
  
module Deduce : sig
  val read_can_like      : [`Read] id    -> [`Like] id
  val read_can_reply     : [`Read] id    -> [`Reply] id
    
  val own_can_remove     : [`Own] id -> [`Remove] id
    
  val created_can_like   : [`Created] id -> [`Like] id
  val created_can_reply  : [`Created] id -> [`Reply] id
  val created_can_remove : [`Created] id -> [`Remove] id
    
  val make_like_token  : [`Unsafe] ICurrentUser.id -> [`Like] id  -> string
  val from_like_token  : [`Unsafe] ICurrentUser.id -> 'any id     -> string -> [`Like] id option
    
  val make_read_token  : [`Unsafe] ICurrentUser.id -> [`Read] id  -> string
  val from_read_token  : [`Unsafe] ICurrentUser.id -> 'any id     -> string -> [`Read] id option
    
  val make_reply_token : [`Unsafe] ICurrentUser.id -> [`Reply] id -> string
  val from_reply_token : [`Unsafe] ICurrentUser.id -> 'any id     -> string -> [`Reply] id option
    
  val make_remove_token : [`Unsafe] ICurrentUser.id -> [`Remove] id -> string
  val from_remove_token : [`Unsafe] ICurrentUser.id -> 'any id      -> string -> [`Remove] id option
end
