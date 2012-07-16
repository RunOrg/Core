(* © 2012 RunOrg *)

type what = [
  `Feed of IFeed.t
]

type status = [ `Block | `Send ]

val block : [`IsSelf] IAvatar.id -> what -> unit O.run

val unblock : [`IsSelf] IAvatar.id -> what -> unit O.run

val status : [`IsSelf] IAvatar.id -> what -> status option O.run

val all_special : what -> < block : IAvatar.t list ; send : IAvatar.t list > O.run
