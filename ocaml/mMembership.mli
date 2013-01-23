(* © 2012 RunOrg *)

module Status : Ohm.Fmt.FMT with type t =
  [ `Unpaid
  | `Pending
  | `Invited
  | `NotMember
  | `Member
  | `Declined ] 

module Diff : Ohm.Fmt.FMT with type t = 
  [ `Invite  of < who : IAvatar.t >
  | `Admin   of < who : IAvatar.t ; what : bool >
  | `User    of < who : IAvatar.t ; what : bool >
  | `Payment of < who : IAvatar.t ; paid : bool >  
  ]

module Details : sig

  type data = {
    where   : IAvatarSet.t  ;
    who     : IAvatar.t ;
    admin   : (bool * float * IAvatar.t) option ; 
    user    : (bool * float * IAvatar.t) option ;
    invited : (bool * float * IAvatar.t) option ;
    paid    : (bool * float * IAvatar.t) option 
  }

end

type t = {
  where   : IAvatarSet.t  ;
  who     : IAvatar.t ;
  admin   : (bool * float * IAvatar.t) option ;
  user    : (bool * float * IAvatar.t) option ;
  invited : (bool * float * IAvatar.t) option ;
  paid    : (bool * float * IAvatar.t) option ;
  mustpay : bool ;
  grant     : [ `Admin | `Token ] option ;
  admin_act : bool ;
  user_act  : bool ;
  time      : float ;
  status    : Status.t 
}

module Signals : sig
  val after_update  : (IMembership.t * t, unit O.run) Ohm.Sig.channel
  val after_version : (<
    mid    : IMembership.t ;
    before : Details.data ;
    time   : float ;
    diffs  : Diff.t list ;
    after  : Details.data
  >, unit O.run) Ohm.Sig.channel 
end

val relevant_change : Details.data -> Diff.t -> bool 

val status : 'any MActor.t -> 'b IAvatarSet.id -> Status.t O.run

val default : mustpay:bool -> group:IAvatarSet.t -> avatar:IAvatar.t -> t

val get : [<`View|`IsSelf|`IsAdmin] IMembership.id -> t option O.run 

val as_admin :
     [<`Admin|`Write|`Bot] IAvatarSet.id
  -> 'a IAvatar.id
  -> [`IsAdmin] IMembership.id O.run

val as_user : 
     'a IAvatarSet.id
  -> 'b MActor.t
  -> [`IsSelf] IMembership.id O.run

val as_viewer :
     [<`List|`Admin|`Write|`Bot] IAvatarSet.id
  -> 'a IAvatar.id 
  -> [`View] IMembership.id O.run

val admin :
     from:'any MActor.t
  -> [<`Admin|`Write|`Bot] IAvatarSet.id
  -> 'a IAvatar.id
  -> [ `Accept of bool | `Invite | `Default of bool ] list
  -> unit O.run

val user : 
     'a IAvatarSet.id
  -> 'b MActor.t
  -> bool
  -> unit O.run

module InGroup : sig

  val all :
       [<`Admin|`Write|`List|`Bot] IAvatarSet.id
    -> MAccess.State.t 
    -> (bool * IAvatar.t) list O.run  
    
  val list_members :
       ?start:Ohm.Id.t
    -> count:int
    -> [<`Admin|`Write|`List|`Bot] IAvatarSet.id 
    -> (IAvatar.t list * Ohm.Id.t option) O.run

  val avatars : 
       [<`Admin|`Write|`List|`Bot] IAvatarSet.id
    -> start:IAvatar.t option
    -> count:int
    -> (IAvatar.t list * IAvatar.t option) O.run
    
  val count : 'any IAvatarSet.id -> < count : int ; pending : int ; any : int > O.run

end

module Mass : sig

  val admin : 
       from:'any MActor.t
    -> [<`Admin|`Write|`Bot] IAvatarSet.id
    -> 'a IAvatar.id list
    -> [ `Accept of bool | `Invite | `Default of bool ] list
    -> unit O.run

  val create : 
       from:'any MActor.t
    -> 'a IInstance.id 
    -> [<`Admin|`Write|`Bot] IAvatarSet.id
    -> ( string * string * string ) list
    -> [ `Accept of bool | `Invite | `Default of bool ] list
    -> unit O.run

end

module Data : sig

  val get : [<`IsSelf|`IsAdmin] IMembership.id -> (string * Ohm.Json.t) list O.run

  val self_update :
       'any IAvatarSet.id
    -> 'b MActor.t
    -> MUpdateInfo.t
    -> ?irreversible:string list
    -> (string * Ohm.Json.t) list
    -> unit O.run

  val admin_update :
       'a MActor.t
    -> [<`Write|`Admin|`Bot] IAvatarSet.id
    -> 'any IAvatar.id
    -> MUpdateInfo.t
    -> (string * Ohm.Json.t) list
    -> unit O.run

  val count :
       [<`Admin|`Write|`List] IAvatarSet.id
    -> string
    -> (Ohm.Json.t * int) list O.run

end

module FieldType : Ohm.Fmt.FMT with type t = MJoinFields.FieldType.t

module Field : sig

  include Ohm.Fmt.FMT with type t = 
    <
      name  : string ;
      label : TextOrAdlib.t ;
      edit  : FieldType.t ;
      required : bool
    > ;;

  val has_stats : t -> bool

end

module Backdoor : sig

  val count : unit -> int O.run

  val make_admin : IAvatar.t -> IInstance.t -> unit O.run

end
