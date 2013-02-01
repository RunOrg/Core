(* © 2013 RunOrg *)

type data = 
    {
      where   : IAvatarSet.t  ;
      who     : IAvatar.t ;
      admin   : (bool * float * IAvatar.t) option ; 
      user    : (bool * float * IAvatar.t) option ;
      invited : (bool * float * IAvatar.t) option ;
      paid    : (bool * float * IAvatar.t) option 
    }
      
include Ohm.Fmt.FMT with type t = data

val invite         : float -> IAvatar.t -> data -> data
val admin_decision : IAvatar.t -> float -> bool -> data -> data
val user_decision  : IAvatar.t -> float -> bool -> data -> data
val payment        : IAvatar.t -> float -> bool -> data -> data

val default : 'g IAvatarSet.id -> 'a IAvatar.id -> data
val last    : data -> float
val status  : manual:bool -> data -> MMembership_status.t
