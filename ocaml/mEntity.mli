(* © 2012 RunOrg *)

(* Types *)

type 'relation t

(* Satellites *) 

module Satellite : sig

  val access : 
       'any t
    -> [ `Wall   of [ `Read | `Write | `Manage ] 
       | `Folder of [ `Read | `Write | `Manage ] 
       | `Album  of [ `Read | `Write | `Manage ]
       | `Votes  of [ `Read | `Vote  | `Manage ]
       | `Group  of [ `Read | `Write | `Manage ] ]
    -> MAccess.t

  val has_votes : 'any t -> bool   

end

(* Signals *)

module Signals : sig
    
  val on_update : ([`Bot] IEntity.id, unit O.run) Ohm.Sig.channel

  val on_bind_group : (   IInstance.t
                        * [`Created] IEntity.id
		        * [`Bot] IGroup.id
                        * ITemplate.t 
			* [`IsSelf] IAvatar.id, unit O.run) Ohm.Sig.channel
    
end

(* Data access *)

module Get : sig 

  val status : 'any t -> [> `Draft | `Website | `Secret ] option

  val deleted       :            'any t -> IAvatar.t option
  val config        :            'any t -> MEntityConfig.t
  val template      :            'any t -> ITemplate.t
  val instance      :            'any t -> IInstance.t
  val kind          :            'any t -> MEntityKind.t
  val template_name :            'any t -> TextOrAdlib.t
  val id            :            'any t -> 'any IEntity.id
  val draft         :            'any t -> bool
  val public        :            'any t -> bool
  val grants        :            'any t -> bool
  val group         : [<`Admin|`View|`Bot] t -> IGroup.t
  val name          : [<`Admin|`View] t -> TextOrAdlib.t option
  val picture       : [<`Admin|`View] t -> [`GetPic] IFile.id option
  val summary       : [<`Admin|`View] t -> TextOrAdlib.t
  val date          : [<`Admin|`View] t -> string option
  val end_date      : [<`Admin|`View] t -> string option
  val admin         :       [<`Admin] t -> MAccess.t 

  val real_access   : [<`Admin|`View] t -> [`Private|`Normal|`Public]
        
  val inactive      :            'any t -> bool

end

module Can : sig

  val admin : 'any t -> [`Admin] t option O.run
  val view  : 'any t -> [`View] t option O.run

  val view_access : 'any t -> MAccess.t

  val set : 
       [`Admin] IEntity.id
    -> who:MUpdateInfo.who
    -> view:[`Private|`Normal|`Public]
    -> admin:MAccess.t
    -> config:MEntityConfig.Diff.t list 
    -> unit O.run

end

module Data : sig

  type 'a t 

  val get : 'any IEntity.id -> 'any t option O.run
    
  val data   : [<`View|`Admin|`Bot] t -> (string * Ohm.Json.t) list
  val name   : [<`View|`Admin|`Bot] t -> TextOrAdlib.t option

  val description : ITemplate.t -> [<`View|`Admin|`Bot] t -> string option

end


val instance : 'any IEntity.id -> IInstance.t option O.run

val try_update : 
     [`IsSelf] IAvatar.id
  -> [`Admin] t
  -> draft:bool
  -> name:TextOrAdlib.t option 
  -> data:(string * Ohm.Json.t) list
  -> view:[`Private|`Normal|`Public]
  -> unit O.run

val set_admins : 
     [`IsSelf] IAvatar.id 
  -> [`Admin] t
  -> MAccess.t
  -> unit O.run 

val delete : 
     [`IsSelf] IAvatar.id
  -> [`Admin] t
  -> unit O.run

val set_picture : 
     [`IsSelf] IAvatar.id 
  -> [`Admin] t
  -> [`InsPic] IFile.id option 
  -> unit O.run 

val bot_get : [`Bot] IEntity.id -> [`Bot] t option O.run

val try_get : 
     'any # MAccess.context
  -> 'some IEntity.id
  -> 'some t option O.run

val naked_get : 'some IEntity.id -> 'some t option O.run

val create : 
      [`IsSelf] IAvatar.id
  ->  name:TextOrAdlib.t option
  -> ?pic:[`InsPic] IFile.id 
  ->  iid:[<`CreateEvent|`CreateGroup|`CreateForum] IInstance.id
  -> ?access:[`Private|`Normal|`Public] 
  ->  ITemplate.t 
  ->  [`Created] IEntity.id O.run

val get_last_real_event_date : [`IsAdmin] IInstance.id -> string option option O.run

val admin_group_name : 'any IInstance.id -> TextOrAdlib.t O.run 

val is_admin : 'any t -> bool O.run
val is_all_members : 'any t -> bool O.run

module All : sig

  val get_by_kind : 
       'any # MAccess.context
    -> MEntityKind.t 
    -> [`View] t list O.run

  val get_administrable_by_kind : 
       'any # MAccess.context
    -> MEntityKind.t 
    -> [`Admin] t list O.run

  val get : 
       'any # MAccess.context
    -> [`View] t list O.run

  val get_with_members : 
       'any # MAccess.context
    -> [`View] t list O.run  

  val get_public :
       IInstance.t
    -> MEntityKind.t
    -> [`View] t list O.run

  val get_future : 
       'any # MAccess.context
    -> [`View] t list O.run

  val get_public_future :
       IInstance.t
    -> [`View] t list O.run

end

val get_if_public : 'any IEntity.id -> [`View] t option O.run

module Backdoor : sig

  val count : (MEntityKind.t * int) list O.run

end

