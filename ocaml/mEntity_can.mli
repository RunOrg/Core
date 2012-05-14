(* © 2012 RunOrg *)

val has_manage_access : MEntity_core.entity -> 'any # MAccess.context -> bool O.run
val has_view_access   : MEntity_core.entity -> 'any # MAccess.context -> bool O.run
val access : unit -> MAccess.of_entity

type 'relation t 

val data : 'any t -> MEntity_core.entity
val id   : 'any t -> 'any IEntity.id

val is_admin : 'any t -> bool O.run

val make : 'any # MAccess.context -> 'relation IEntity.id -> MEntity_core.entity -> 'relation t
val make_full  :                     'relation IEntity.id -> MEntity_core.entity -> 'relation t
val make_naked :                     'relation IEntity.id -> MEntity_core.entity -> 'relation t
val make_visible :                   'relation IEntity.id -> MEntity_core.entity -> 'relation t
 
val make_public : 'any IEntity.id -> MEntity_core.entity -> [`View] t option

val admin : 'any t -> [`Admin] t option O.run
val view  : 'any t -> [`View]  t option O.run

val view_access : 'any t -> MAccess.t

val set : 
     [`Admin] IEntity.id
  -> who:MUpdateInfo.who
  -> view:[`Private|`Normal|`Public]
  -> admin:MAccess.t
  -> config:MEntityConfig.Diff.t list 
  -> unit O.run
