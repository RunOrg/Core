(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

include Fmt.Make(struct
  type json t = 
    [ `NewWallItem   "ni" of [ `WallReader "r" | `WallAdmin "a" ]
    | `NewFavorite   "nf" of [ `ItemAuthor "a" ]
    | `NewComment    "nc" of [ `ItemAuthor "a" | `ItemFollower "i" ]
    | `BecomeMember  "bm"
    | `BecomeAdmin   "ba"
    | `SuperAdmin    "sa"
    | `EntityInvite  "ei"
    | `EntityRequest "er"	
    | `Broadcast     "b"
    ]
end)
