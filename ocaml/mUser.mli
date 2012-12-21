(* © 2012 RunOrg *)

module Notification : Ohm.Fmt.FMT with type t = 
  [ `message
  | `myMembership 
  | `likeItem
  | `commentItem
  | `welcome 
  | `subscription 
  | `event
  | `forum
  | `album
  | `group
  | `poll
  | `course
  | `item
  | `pending
  | `digest
  | `networkInvite
  | `chatReq ]

type t = <
  firstname : string option ;
  lastname  : string option ;
  fullname  : string ;
  passhash  : string option ;
  email     : string ;
  emails    : (string * bool) list ;
  autologin : bool ;
  confirmed : bool ;
  destroyed : float option ;
  facebook  : OhmFacebook.t option ;
  picture   : [`GetPic] IFile.id option ;
  birthdate : Date.t option ;
  phone     : string option ;
  cellphone : string option ;
  address   : string option ;
  zipcode   : string option ;
  city      : string option ;
  country   : string option ;
  gender    : [`m|`f] option ;
  share     : MFieldShare.t list ;
  blocktype : Notification.t list ;
  joindate  : float ;
  white     : IWhite.t option 
> ;;

module Registry : OhmCouchRegistry.REGISTRY with type id = IUser.t

module Signals : sig

  val on_create     : ([`Created] IUser.id * t, unit O.run) Ohm.Sig.channel
  val on_update     : ([`Updated] IUser.id * t, unit O.run) Ohm.Sig.channel
  val on_confirm    : (IUser.t * t, unit O.run) Ohm.Sig.channel
  val on_obliterate : (IUser.t, unit O.run) Ohm.Sig.channel 
  val on_merge      : (IUser.t * IUser.t, unit O.run) Ohm.Sig.channel 

end

val by_email : string -> IUser.t option O.run
val by_facebook : OhmFacebook.t -> IUser.t option O.run

class type user_short = object
  method firstname : string
  method lastname  : string
  method password  : string option 
  method email     : string
  method white     : IWhite.t option
end

val quick_create : user_short -> [ `created   of [`New] ICurrentUser.id 
				 | `duplicate of IUser.t ] O.run

val listener_create : string -> [`New] ICurrentUser.id option O.run

val add_email : 
     uid:[`Edit] IUser.id
  -> email:string
  -> [ `missing | `prove of string | `ok ] O.run

val confirm_email : 
     uid:[`Edit] IUser.id 
  -> proof:string
  -> [ `missing | `taken | `ok ] O.run

val merge_unconfirmed : 
     merged:[`IsSelf] IUser.id
  -> into:[`IsSelf] IUser.id
  -> unit O.run

val facebook_create : 
  OhmFacebook.t -> OhmFacebook.details -> IUser.t option O.run

val facebook_bind :
  [`Confirm] IUser.id ->  OhmFacebook.t -> OhmFacebook.details -> bool O.run

class type user_full = object
  method firstname : string
  method lastname  : string
  method email     : string
  method birthdate : Date.t option
  method phone     : string option
  method cellphone : string option
  method address   : string option
  method zipcode   : string option
  method city      : string option
  method country   : string option
  method picture   : [`GetPic] IFile.id option 
  method gender    : [`m|`f] option
  method white     : IWhite.t option 
end

class type user_edit = object
  method firstname : string
  method lastname  : string
  method birthdate : Date.t option
  method phone     : string option
  method cellphone : string option
  method address   : string option
  method zipcode   : string option
  method city      : string option
  method country   : string option
  method gender    : [`m|`f] option
end

val user_bind : user_full -> IUser.t O.run

val update : [`Edit] IUser.id -> user_edit -> unit O.run

val set_pic : [`Edit] IUser.id -> [`OwnPic] IFile.id option -> unit O.run

val get : [<`View|`Bot] IUser.id -> (#Ohm.CouchDB.ctx,t option) Ohm.Run.t

val knows_password : string -> 'any IUser.id -> [`Old] ICurrentUser.id option O.run

val confirm : [`Confirm] IUser.id -> bool O.run

val confirmed : 'any IUser.id -> bool O.run
val confirmed_time : [<`Bot] IUser.id -> float option O.run

val set_password : string -> 'any ICurrentUser.id -> unit O.run
  
val blocks : 'any IUser.id -> Notification.t list O.run

module Share : sig

  val set : [`IsSelf] IUser.id -> MFieldShare.t list -> unit O.run

end

val obliterate : [`Unsubscribe] IUser.id -> [`ok|`missing|`destroyed] O.run

val all_ids : count:int -> IUser.t option -> (IUser.t list * IUser.t option) O.run

module Backdoor : sig

  val count_confirmed : int O.run
  val count_undeleted : int O.run

  val list : count:int -> IUser.t option -> ((IUser.t * t) list * IUser.t option) O.run

  val all : (IUser.t * <
        firstname : string option ;
        lastname  : string option ;
	email     : string ;
	join      : float
      >) list O.run

  val unsubscribed : count:int -> (<
    email : string ;
    time  : float ; 
  >) list O.run

end
