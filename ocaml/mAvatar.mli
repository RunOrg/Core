(* © 2013 RunOrg *)

module Status : Ohm.Fmt.FMT with type t = 
  [ `Admin | `Token |` Contact ]

module Signals : sig

  val on_update     : (IAvatar.t * IInstance.t, unit O.run) Ohm.Sig.channel 
  val on_obliterate : (IAvatar.t * IInstance.t, unit O.run) Ohm.Sig.channel

  (* Used when performing a global refresh on all avatars *)
  val refresh_grant : (IAvatar.t, unit O.run) Ohm.Sig.channel

end

module Notify : sig

  type t = 
    [ `UpgradeToAdmin  of IUser.t * IInstance.t * IAvatar.t
    | `UpgradeToMember of IUser.t * IInstance.t * IAvatar.t
    ]

  val define : 
    ([`IsSelf] IUser.id -> MUser.t -> t -> MMail.Types.info -> MMail.Types.render option O.run) -> unit  

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

val get_user     : 'any IAvatar.id -> IUser.t option O.run
val get_instance : 'any IAvatar.id -> IInstance.t option O.run 

val upgrade_to_admin     :
  ?from:[`IsSelf] IAvatar.id -> [`Bot] IAvatar.id -> unit O.run

val change_to_member     : 
  ?from:[`IsSelf] IAvatar.id -> [`Bot] IAvatar.id -> unit O.run

val downgrade_to_contact : 
  ?from:[`IsSelf] IAvatar.id -> [`Bot] IAvatar.id -> unit O.run

val become_contact : 'a IInstance.id -> 'b IUser.id -> IAvatar.t O.run
val become_admin   : [`Created] IInstance.id -> 'any IUser.id -> IAvatar.t O.run

val identify : 'any IInstance.id -> [`Old] ICurrentUser.id -> (#O.ctx,[`IsContact] MActor.t option) Ohm.Run.t
val find : 'a IInstance.id -> 'b IUser.id -> (#O.ctx,IAvatar.t option) Ohm.Run.t

val actor : [`IsSelf] IAvatar.id -> (#O.ctx,[`IsContact] MActor.t option) Ohm.Run.t

val collect_profile : MProfile.Data.t -> < 
  name : string option ;
  sort : string list ; 
  picture : IFile.t option ;
  role : string option
> 

val status : 'a IInstance.id -> 'b ICurrentUser.id -> ( #Ohm.CouchDB.ctx, Status.t ) Ohm.Run.t 

val profile : 'a IAvatar.id -> IProfile.t O.run

val my_profile : [`IsSelf] IAvatar.id -> [`IsSelf] IProfile.id O.run

val search : 
     [`ViewContacts] IInstance.id
  -> string
  -> int
  -> (IAvatar.t * string * details) list O.run

val user_instances : 
     ?status:Status.t
  -> ?count:int
  ->  [`ViewInstances] IUser.id
  ->  ( #Ohm.CouchDB.ctx, (Status.t * [`IsContact] IInstance.id) list ) Ohm.Run.t

val user_avatars :
  [`IsSelf] IUser.id
  -> ( #Ohm.CouchDB.ctx, [`IsToken] MActor.t list ) Ohm.Run.t

val count_user_instances :
     [`ViewInstances] IUser.id
  -> ( #Ohm.CouchDB.ctx, int ) Ohm.Run.t

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

val by_status : 
     [`ViewContacts] IInstance.id 
  -> ?start:IAvatar.t 
  -> count:int
  -> Status.t 
  -> (IAvatar.t list * IAvatar.t option) O.run

module Backdoor : sig

  val user_instances : 
       ?status:Status.t
    -> ?count:int
    ->  'any IUser.id 
    ->  (Status.t * [`IsContact] IInstance.id) list O.run

  val all : (IUser.t * IInstance.t * Status.t) list O.run 

  val count : int O.run

  val list : count:int -> IAvatar.t option -> ((IUser.t * IInstance.t * Status.t) list * IAvatar.t option) O.run

  val instance_member_count : [`Admin] ICurrentUser.id -> IInstance.t -> (#O.ctx, int) Ohm.Run.t

  val instance_admins : [`Admin] ICurrentUser.id -> IInstance.t -> (#O.ctx, details list) Ohm.Run.t

  val refresh_grants : unit -> unit O.run

  val refresh_avatar_atoms : unit -> unit O.run
	
end



