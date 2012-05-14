(* © 2012 RunOrg *)

type access = {
  avatars : IAvatar.t list ;
  groups  : IGroup.t list ;
}

val field : ctx:[<`IsAdmin|`IsToken] CContext.full -> (
  label : Ohm.I18n.text ->
  ?minitip : Ohm.I18n.text -> 
  ('seed -> access) ->
  ('seed,access option) Ohm.Joy.template
) O.run

val extract : MAccess.t -> access
val apply : MAccess.t -> access -> MAccess.t
