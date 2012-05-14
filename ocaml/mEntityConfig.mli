(* © 2012 MRunOrg *)

include Ohm.Fmt.FMT with type t = <
  group : <
    waiting_list : [`manual|`none] ;
    payment      : [`none] ;
    validation   : [`manual|`none] ;
    semantics    : [`group|`event] ;
    grant_tokens : [`yes|`no] ;
    read         : [`Viewers|`Registered|`Managers] ;
  > option ;
  wall : <
    read         : [`Viewers|`Registered|`Managers] ;
    post         : [`Viewers|`Registered|`Managers] ;
  > option ;
  folder : <
    read         : [`Viewers|`Registered|`Managers] ;
    post         : [`Viewers|`Registered|`Managers] ;
  > option ;
  album : <
    read         : [`Viewers|`Registered|`Managers] ;
    post         : [`Viewers|`Registered|`Managers] ;
  > option ;
  votes : <
    read         : [`Viewers|`Registered|`Managers] ;
    vote         : [`Viewers|`Registered|`Managers] ;
  > option 
>

val default : t

module Diff : Ohm.JoyA.FMT with type t = 
  [ `NoGroup 
  | `Group_WaitingList of [`manual|`none]
  | `Group_Payment of [`none]
  | `Group_Validation of [`manual|`none]
  | `Group_PublicList of bool
  | `Group_Semantics of [`group|`event]
  | `Group_GrantTokens of [`yes|`no]
  | `Group_Read of [`Viewers|`Registered|`Managers] 
  | `NoWall
  | `Wall_Hidden of bool
  | `Wall_Read   of [`Viewers|`Registered|`Managers] 
  | `Wall_Write  of [`Viewers|`Registered|`Managers] 
  | `NoAlbum
  | `Album_Hidden of bool
  | `Album_Read   of [`Viewers|`Registered|`Managers] 
  | `Album_Write  of [`Viewers|`Registered|`Managers] 
  | `NoFolder
  | `Folder_Hidden of bool
  | `Folder_Read   of [`Viewers|`Registered|`Managers] 
  | `Folder_Write  of [`Viewers|`Registered|`Managers] 
  | `NoVotes
  | `Votes_Read of [`Viewers|`Registered|`Managers] 
  | `Votes_Vote of [`Viewers|`Registered|`Managers] 
  ]

val names : Diff.t -> (string * string) list

val apply_diff : t -> Diff.t list -> t
