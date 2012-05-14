(* © 2012 RunOrg *)

val renderer :
     [`ViewContacts] IInstance.id option 
  -> 'any CContext.full
  -> ( (('prefix * IAvatar.t option) O.Box.box_context -> Ohm.View.html)
       -> ('prefix * IAvatar.t option) O.box)
  -> ('prefix * IAvatar.t option) O.box
