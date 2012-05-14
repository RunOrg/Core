(* © 2012 RunOrg *)

val contact_picker :
     MInstance.t
  -> [`ViewContacts] IInstance.id
  -> 'any IIsIn.id
  -> Ohm.I18n.t
  -> Js.id
  -> string
  -> Ohm.View.html

val grab_selected : < post : string -> string option ; .. > -> IAvatar.t list option 

val add_to_group : 
     self:[ `IsSelf ] IAvatar.id 
  -> avatar:IAvatar.t
  -> group:[< `Admin | `Write ] MGroup.t
  -> on_add:[ `add | `ignore | `invite ]
  -> unit O.run
