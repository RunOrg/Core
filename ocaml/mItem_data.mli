(* © 2013 RunOrg *)

include Ohm.Fmt.FMT with type t = 
  <
    del     : bool ;
    delayed : bool ;
    where   : [`Unknown] MItem_common.source ;
    payload : MItem_payload.t ; 
    time    : float ; 
    clike   : IAvatar.t list ;
    nlike   : int ;
    ccomm   : IComment.t list ;
    ncomm   : int ;
    iid     : IInstance.t 
  >

val author : t -> IAvatar.t option
