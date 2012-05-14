(* © 2012 RunOrg *)

module Validate : sig

  val reaction : 
       ctx:'any CContext.full
    -> group:[< `Admin | `Write ] MGroup.t
    -> (O.Box.reaction -> 'a O.box)
    -> 'a O.box

end

val contact_picker :
     MInstance.t
  -> [`ViewContacts] IInstance.id
  -> 'any IIsIn.id
  -> Ohm.I18n.t
  -> Js.id
  -> string
  -> Ohm.View.html

module Link : sig

  val link_box : 
       ctx:[`IsToken] CContext.full
    -> entity:[<`Admin|`View] MEntity.t
    -> group:[`Admin] MGroup.t
    -> 'c O.box

end

module Picker : sig

  val configure : 
    [`ViewContacts] IInstance.id ->
    ctx:'any CContext.full -> 
    (format: IAvatar.t Ohm.Fmt.t -> source:[>`Dynamic of string] -> 'a) ->
    'a
      
end
