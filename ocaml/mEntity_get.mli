(* © 2012 RunOrg *)

type 'a t = 'a MEntity_can.t 

val status : 'any t -> [`Draft | `Active | `Delete ]

val deleted       : 'any t -> IAvatar.t option
val config        : 'any t -> MEntityConfig.t
val template      : 'any t -> ITemplate.t
val instance      : 'any t -> IInstance.t
val kind          : 'any t -> MEntityKind.t
val template_name : 'any t -> Ohm.I18n.text
val id            : 'any t -> 'any IEntity.id
val draft         : 'any t -> bool
val public        : 'any t -> bool
val grants        : 'any t -> bool
val group         : 'any t -> IGroup.t 
val name          : 'any t -> Ohm.I18n.text option
val on_add        : 'any t -> [ `ignore | `invite | `add ] 
val picture       : 'any t -> [`GetPic] IFile.id option
val summary       : 'any t -> Ohm.I18n.text 
val date          : 'any t -> string option
val end_date      : 'any t -> string option
val admin         : 'any t -> MAccess.t

val real_access   : 'any t -> [ `Admin | `Normal | `Invite | `Registered | `Public ]
  
val inactive      : 'any t -> bool

