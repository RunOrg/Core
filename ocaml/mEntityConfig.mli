(* © 2012 RunOrg *)

module WithDefault : sig
  type 'a t = [ `Some of 'a | `None | `Default ]
end

include Ohm.Fmt.FMT with type t = <
  group : <
    validation : [`Manual|`None] ;
    read       : [`Viewers|`Registered|`Managers] ;
  > WithDefault.t ;
  wall : <
    read         : [`Viewers|`Registered|`Managers] ;
    post         : [`Viewers|`Registered|`Managers] ;
  > WithDefault.t ;
  folder : <
    read         : [`Viewers|`Registered|`Managers] ;
    post         : [`Viewers|`Registered|`Managers] ;
  > WithDefault.t ;
  album : <
    read         : [`Viewers|`Registered|`Managers] ;
    post         : [`Viewers|`Registered|`Managers] ;
  > WithDefault.t ;
  votes : <
    read         : [`Viewers|`Registered|`Managers] ;
    vote         : [`Viewers|`Registered|`Managers] ;
  > WithDefault.t 
>

val group : ITemplate.t -> t -> <
  validation : [`Manual|`None] ;
  read       : [`Viewers|`Registered|`Managers]
> option

val wall : ITemplate.t -> t -> <
  read : [`Viewers|`Registered|`Managers] ;
  post : [`Viewers|`Registered|`Managers] ;
> option

val folder : ITemplate.t -> t -> <
  read : [`Viewers|`Registered|`Managers] ;
  post : [`Viewers|`Registered|`Managers] ;
> option

val album : ITemplate.t -> t -> <
  read : [`Viewers|`Registered|`Managers] ;
  post : [`Viewers|`Registered|`Managers] ;
> option

val votes : ITemplate.t -> t -> <
  read : [`Viewers|`Registered|`Managers] ;
  vote : [`Viewers|`Registered|`Managers] ;
> option

val default : t

module Diff : Ohm.Fmt.FMT with type t = 
  [ `NoGroup 
  | `Group_WaitingList of [`manual|`none]
  | `Group_Payment of [`none]
  | `Group_Validation of [`Manual|`None]
  | `Group_PublicList of bool
  | `Group_Semantics of [`Group|`Event]
  | `Group_GrantTokens of [`Yes|`No]
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

val apply_diff : ITemplate.t -> t -> Diff.t list -> t
