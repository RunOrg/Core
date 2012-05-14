(* © 2012 RunOrg *)

val name : string

val with_logout_cookie : O.Action.response -> O.Action.response

val with_login_cookie : [ `CanLogin ] IUser.id -> bool -> O.Action.response -> O.Action.response

val unverified_user_id : string -> IUser.t option

val get_login_cookie : string -> [`Unsafe] ICurrentUser.id option

val read_login_cookie : 
     string
  -> success:([ `Unsafe ] ICurrentUser.id -> O.Action.response -> 'a)
  -> fail:(O.Action.response -> 'a) 
  -> O.Action.response
  -> 'a

val with_tracking_cookie : 
  < cookie : string -> string option ; .. >
  -> (string -> O.Action.response)
  -> O.Action.response
