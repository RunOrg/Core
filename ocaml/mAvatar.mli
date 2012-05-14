(* © 2012 RunOrg *)

module Status : Ohm.Fmt.FMT with type t = 
  [ `Admin | `Token |` Contact ]

val refresh : [<`IsAdmin|`IsToken|`IsContact] IIsIn.id -> unit O.run

module Signals : sig

  type status_event = [`IsSelf] IAvatar.id option * IAvatar.t * IInstance.t

  val on_update               : (IAvatar.t * IInstance.t, unit O.run) Ohm.Sig.channel 
  val on_upgrade_to_admin     : (status_event, unit O.run) Ohm.Sig.channel
  val on_upgrade_to_member    : (status_event, unit O.run) Ohm.Sig.channel
  val on_downgrade_to_member  : (status_event, unit O.run) Ohm.Sig.channel
  val on_downgrade_to_contact : (status_event, unit O.run) Ohm.Sig.channel

  val on_merge : (IAvatar.t * IAvatar.t, unit O.run) Ohm.Sig.channel 

  val on_obliterate : (IAvatar.t * IInstance.t, unit O.run) Ohm.Sig.channel

end

module Pending : sig

  val get_latest_confirmed :
       count:int
    -> ?start:(float * IAvatar.t)
    -> [`IsAdmin] IInstance.id
    -> ((IAvatar.t * float) list * (float * IAvatar.t) option) O.run
    
end

type details = <
  name    : string option ;
  sort    : string option ;
  picture : [`GetPic] IFile.id option ;
  ins     : IInstance.t option ;
  who     : IUser.t option ;
  status  : Status.t option ;
  role    : string option ;
>

val exists      : 'any IAvatar.id -> bool O.run

val details     : 'any IAvatar.id -> details O.run

val get_user    : 'any IAvatar.id -> IUser.t option O.run

val upgrade_to_admin     :
  ?from:[`IsSelf] IAvatar.id -> [`Bot] IAvatar.id -> unit O.run

val downgrade_to_member  : 
  ?from:[`IsSelf] IAvatar.id -> [`Bot] IAvatar.id -> unit O.run

val upgrade_to_member    :
  ?from:[`IsSelf] IAvatar.id -> [`Bot] IAvatar.id -> unit O.run

val downgrade_to_contact : 
  ?from:[`IsSelf] IAvatar.id -> [`Bot] IAvatar.id -> unit O.run

val change_to_member     : 
  ?from:[`IsSelf] IAvatar.id -> [`Bot] IAvatar.id -> unit O.run

val become_contact : 'a IInstance.id -> 'b IUser.id -> IAvatar.t O.run
val become_admin   : 
  [`Created] IInstance.id -> [`IsSelf] IUser.id -> [`IsAdmin] IIsIn.id option O.run

val identify : 'any IInstance.id -> [`Unsafe] ICurrentUser.id -> 'any IIsIn.id O.run
val identify_user : 'a IInstance.id -> [`IsSelf] IUser.id -> 'a IIsIn.id O.run
val identify_avatar : [`IsSelf] IAvatar.id -> [`IsContact] IIsIn.id option O.run

val profile : 'a IAvatar.id -> IProfile.t O.run

val get : 'any IIsIn.id -> [`IsSelf] IAvatar.id O.run

val usage : [<`ViewContacts|`SeeUsage] IInstance.id -> int O.run

val search : 
     [`ViewContacts] IInstance.id
  -> string
  -> int
  -> (IAvatar.t * string * details) list O.run

val user_instances : 
     ?status:Status.t
  -> ?count:int
  ->  [`ViewInstances] IUser.id
  ->  (Status.t * [`IsContact] IInstance.id) list O.run

val list_members : 
     ?start:string
  -> count:int
  -> [`ViewContacts] IInstance.id 
  -> (IAvatar.t list * string option) O.run

val list_administrators : 
     ?start:string
  -> count:int
  -> 'any IInstance.id 
  -> (IAvatar.t list * string option) O.run

val by_status : [`ViewContacts] IInstance.id -> Status.t -> IAvatar.t list O.run

val is_admin : ?other_than:IInstance.t -> 'any IUser.id -> bool O.run

module List : sig

  val with_pictures : 
      count:int
    -> [`ViewContacts] IInstance.id
    -> IAvatar.t list O.run

  val all_members : [`Bot] IInstance.id -> IAvatar.t list O.run
    
end

module Backdoor : sig

  val user_instances : 
       ?status:Status.t
    -> ?count:int
    ->  'any IUser.id 
    ->  (Status.t * [`IsContact] IInstance.id) list O.run

  val all : (IUser.t * IInstance.t * Status.t) list O.run 

end
