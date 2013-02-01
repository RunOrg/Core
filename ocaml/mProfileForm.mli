(* © 2013 RunOrg *)

module Info : sig
  type t = {
    aid : IAvatar.t ;
    iid : IInstance.t ;
    kind : IProfileForm.Kind.t ;
    name : MRich.OrText.t ;
    hidden : bool ;
    created : float * IAvatar.t ;
    updated : (float * IAvatar.t) option 
  }
end

type data = (string * Ohm.Json.t) list

val create : 
     [`IsAdmin] MActor.t
  -> IAvatar.t 
  -> kind:IProfileForm.Kind.t
  -> hidden:bool 
  -> name:MRich.OrText.t
  -> data:data
  -> IProfileForm.t O.run

val update : 
     [`Edit] IProfileForm.id
  -> ?hidden:bool
  -> ?name:MRich.OrText.t
  -> ?data:data
  -> 'any MActor.t
  -> unit O.run

val get : [<`Edit|`View] IProfileForm.id -> Info.t option O.run
val get_data : [<`Edit|`View] IProfileForm.id -> data O.run

val as_admin :
     'any IProfileForm.id 
  -> [`IsAdmin] MActor.t
  -> [`Edit] IProfileForm.id 

val as_myself : 
     'any IProfileForm.id 
  -> [`IsToken] MActor.t
  -> [`View] IProfileForm.id option O.run

val access : 
     'any IProfileForm.id 
  -> [`IsToken] MActor.t
  -> [ `None
     | `View of [`View] IProfileForm.id 
     | `Edit of [`Edit] IProfileForm.id ] O.run

module All : sig

  val by_avatar :
       IAvatar.t 
    -> [`IsAdmin] MActor.t
    -> ([`Edit] IProfileForm.id * Info.t) list O.run

  val mine : 
       [`IsToken] MActor.t
    -> ([`View] IProfileForm.id * Info.t) list O.run 

  val as_parent :
       IAvatar.t 
    -> [`IsToken] MActor.t
    -> ([`View] IProfileForm.id * Info.t) list O.run

end 
