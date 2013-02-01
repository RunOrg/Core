(* © 2013 RunOrg *)

module Unbound : sig
  type t = {
    name : string ;
    site : string option ;
    request : string ;
    owners : IUser.t list 
  }
end

module Data : sig
  type t = {
    related_to : IInstance.t ;
    created_by : IAvatar.t ;
    created_on : float ;
    access     : [ `Public | `Private ] ;
    bind       : [ `Unbound of Unbound.t
		 | `Bound   of IInstance.t ] ;
    profile    : IInstance.t option 
  }
end

module Signals : sig

  type owner_request = 
    [`IsSelf] IAvatar.id * [`Own] IRelatedInstance.id * string * IUser.t

  val add_owner : (owner_request, unit O.run) Ohm.Sig.channel 

  type connection = <
    relation : IRelatedInstance.t ;
    follower : IInstance.t ;
    followed : IInstance.t
  >

  val after_connect : (connection, unit O.run) Ohm.Sig.channel

end

type description = <
  name        : string option ;
  site        : string option ;
  url         : [`None|`Site of string|`Key of IWhite.key|`Profile of IInstance.t] ;
  picture     : [`GetPic] IFile.id option ;
  access      : [`Public|`Private] ;
  profile     : IInstance.t option 
> ;;

val is_bound : Data.t -> bool

val describe : Data.t -> description O.run

type viewable = [`View]  IRelatedInstance.id * Data.t

val get_all_public  :            IInstance.t  -> viewable list O.run
val get_all         : [`IsToken] IInstance.id -> viewable list O.run
val get_all_mine    :    'any ICurrentUser.id -> viewable list O.run

val get_data : [<`Own|`Admin|`View] IRelatedInstance.id -> Data.t option O.run

val get_own : 'any ICurrentUser.id -> 'b IRelatedInstance.id -> ([`Own] IRelatedInstance.id * Data.t) option O.run

val get : 'a MActor.t -> 'b IRelatedInstance.id ->
  [ `None
  | `View  of [`View]  IRelatedInstance.id * Data.t
  | `Admin of [`Admin] IRelatedInstance.id * Data.t
  ] O.run

val get_follower : IRelatedInstance.t -> IInstance.t option O.run

val get_listened : IInstance.t -> IInstance.t list O.run

val get_listeners : IInstance.t -> IInstance.t list O.run

val bind_to : [`Own] IRelatedInstance.id -> [`IsAdmin] IInstance.id -> unit O.run

val count : 'any IInstance.id -> < following : int ; followers : int > O.run 

val follow :   
     [`IsAdmin] IInstance.id
  -> [`IsSelf] IAvatar.id
  -> IInstance.t
  -> unit O.run

val create : 
     [<`IsAdmin|`IsToken] IInstance.id
  -> [`IsSelf] IAvatar.id
  -> name:string
  -> request:string 
  -> owners:IUser.t list
  -> site:string option
  -> access:[`Public | `Private]
  -> [`Admin] IRelatedInstance.id O.run

val update_unbound : 
     [`Admin] IRelatedInstance.id
  -> name:string
  -> site:string option
  -> access:[`Public | `Private] 
  -> unit O.run

val update_bound : 
  [`Admin] IRelatedInstance.id
  -> access:[`Public | `Private] 
  -> unit O.run

val decline :
     [`Own] IRelatedInstance.id
  -> 'any ICurrentUser.id
  -> unit O.run

val send_requests : 
     [`Admin] IRelatedInstance.id
  -> [`IsSelf] IAvatar.id
  -> string
  -> IUser.t list
  -> unit O.run

module Backdoor : sig

  val count : < bound : int ; unbound : int > O.run

  val latest : (IRelatedInstance.t * Data.t) list O.run

  val set_profile : IRelatedInstance.t -> IInstance.t -> unit O.run

end
