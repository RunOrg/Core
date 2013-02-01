(* © 2013 RunOrg *)

include Ohm.Fmt.FMT with type t = 
  [ `NewWallItem of [ `WallReader | `WallAdmin ]
  | `NewFavorite of [ `ItemAuthor ]
  | `NewComment  of [ `ItemAuthor | `ItemFollower ]
  | `BecomeMember
  | `BecomeAdmin
  | `EventInvite
  | `EntityRequest
  | `Broadcast
  | `SuperAdmin
  | `CanInstall
  ]

