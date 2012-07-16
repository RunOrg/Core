(* © 2012 RunOrg *)
    
type t = <
  t     : MType.t ;
  who   : IAvatar.t ;
  what  : string ;
  time  : float ;
  on    : IItem.t 
> ;;

module Signals : sig
    
  val on_create : ([`Created] IComment.id * t, unit O.run) Ohm.Sig.channel
  val on_delete : (IComment.t * IItem.t, unit O.run) Ohm.Sig.channel 
    
end

val max_length : int
  
val create : 
     [`Reply] IItem.id
  -> [`IsSelf] IAvatar.id 
  -> string
  -> ([`Created] IComment.id * t) O.run

val all : [`Read] IItem.id -> ([`Read] IComment.id * t) list O.run
  
val get : [`Read] IComment.id -> t option O.run
  
val try_get : 
     [`Read] IItem.id
  -> 'any IComment.id
  -> ([`Read] IComment.id * t) option O.run

val item : 'a IComment.id -> IItem.t option O.run 

val interested : [`Bot] IItem.id -> IAvatar.t list O.run
  
module Backdoor : sig
  val count : int O.run
end
 
