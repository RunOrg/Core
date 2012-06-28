(* © 2012 RunOrg *)

val reply : 'any CAccess.t -> [`Reply] IItem.id -> Ohm.Html.writer O.run

val render_by_id : [`Read] IComment.id -> Ohm.Html.writer option O.run
