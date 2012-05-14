(* © 2012 RunOrg *)

val home_box :
     iid:[`ViewContacts] IInstance.id
  -> ctx : 'any CContext.full
  -> 'box O.box

val admins_box :
      ctx:[`IsAdmin] CContext.full
  -> 'box O.box

val entity_box :
     gid:[< `Admin | `Bot | `List | `Write ] IGroup.id
  -> ctx : 'any CContext.full
  -> 'box O.box
