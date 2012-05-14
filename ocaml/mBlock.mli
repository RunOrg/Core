(* © 2012 RunOrg *)

type what = [
  `Feed of IFeed.t
]

val block : [`IsSelf] IAvatar.id -> what -> unit O.run

val unblock : [`IsSelf] IAvatar.id -> what -> unit O.run

val is_blocked : [`IsSelf] IAvatar.id -> what -> bool O.run

val all_blockers : what -> IAvatar.t BatPSet.t O.run
