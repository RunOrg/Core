(* © 2012 RunOrg *)

val pick_templates :
     templates:([`Create] ITemplate.id * MVertical.Template.t) list
  -> title:Ohm.I18n.text
  -> ctx:[< `IsAdmin | `IsContact | `IsMember ] CContext.full
  -> (O.Box.reaction -> 'b O.box)
  -> 'b O.box

