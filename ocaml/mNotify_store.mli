(* © 2012 RunOrg *)

module Data : sig
  type t = {
    payload     : MNotify_payload.t ;
    created     : float ;
    uid         : IUser.t ;
    seen        : float option ;
    sent        : (float * string) option ;
    mail_clicks : int ;
    site_clicks : int ;
    rotten      : bool ;
    delayed     : bool ;
    stats       : INotifyStats.t option 
  }
end

module MyTable : Ohm.CouchDB.TABLE with type id = INotify.t and type elt = Data.t
module Design : Ohm.CouchDB.DESIGN

type t = <
  id      : INotify.t ; 
  payload : MNotify_payload.t ;
  time    : float ;
  seen    : bool 
>

val create : ?stats:INotifyStats.t -> MNotify_payload.t -> IUser.t -> unit O.run

val get_mine : 'any ICurrentUser.id -> INotify.t -> t option O.run 

val all_mine : count:int -> ?start:float -> 'any ICurrentUser.id -> (t list * float option) O.run  

val count_mine : 'any ICurrentUser.id -> int O.run 

val rotten : INotify.t -> unit O.run 
