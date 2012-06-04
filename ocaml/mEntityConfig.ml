(* © 2012 RunOrg *)

open Ohm

module WithDefault = struct
  type 'a t = [ `Some of 'a | `None | `Default ] 
  let to_json json_of_t = function
    | `Some t  -> json_of_t t 
    | `None    -> Json.Null
    | `Default -> Json.String "d"
  let of_json t_of_json = function
    | Json.Null       -> `None
    | Json.String "d" -> `Default
    | json            -> `Some (t_of_json json)
end

include Fmt.Make(struct
  type json t = <
   ?group : <
     ?waiting_list : [`manual|`none] = `none ;
     ?payment      : [`none] = `none ;
     ?validation   : [`manual|`none] = `none ;
     ?read         : [`Viewers|`Registered|`Managers] = `Viewers ;
     ?semantics    : [`group|`event] = `event ;
     ?grant_tokens : [`yes|`no] = `no 
    > WithDefault.t = `None;
   ?wall : <
     ?read         : [`Viewers|`Registered|`Managers] = `Viewers ;
     ?post         : [`Viewers|`Registered|`Managers] = `Viewers 
    > WithDefault.t = `None ;
   ?folder : <
     ?read         : [`Viewers|`Registered|`Managers] = `Viewers ;
     ?post         : [`Viewers|`Registered|`Managers] = `Viewers 
    > WithDefault.t = `None ;
   ?album : <
     ?read         : [`Viewers|`Registered|`Managers] = `Viewers ;
     ?post         : [`Viewers|`Registered|`Managers] = `Viewers 
    > WithDefault.t = `None ;
   ?votes : <
     ?read         : [`Viewers|`Registered|`Managers] = `Viewers ;
     ?vote         : [`Viewers|`Registered|`Managers] = `Viewers 
    > WithDefault.t = `None
  >
end)

let default = of_json (Json.Object [
  "group",  Json.Object [] ;
  "wall",   Json.Object [] ;
  "album",  Json.Object [] ;
  "folder", Json.Object [] ;
  "votes",  Json.Object [] 
]) 

let default_group  = BatOption.get default # group
let default_wall   = BatOption.get default # wall
let default_album  = BatOption.get default # album
let default_folder = BatOption.get default # folder
let default_votes  = BatOption.get default # votes 

module Diff = Fmt.Make(struct
  type json t = 
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
    | `Votes_Read    of [`Viewers|`Registered|`Managers] 
    | `Votes_Vote    of [`Viewers|`Registered|`Managers] 
    ]
end)

let names _ = []

class editable_group ?(group=default_group) () = object

  val waiting_list = group # waiting_list
  val payment      = group # payment
  val validation   = group # validation
  val semantics    = group # semantics
  val grant_tokens = group # grant_tokens 
  val read         = group # read

  method waiting_list = ( waiting_list : [`manual|`none])
  method payment      = ( payment      : [`none])
  method validation   = ( validation   : [`manual|`none])
  method semantics    = ( semantics    : [`group|`event])
  method grant_tokens = ( grant_tokens : [`yes|`no] )
  method read         = ( read         : [`Viewers|`Registered|`Managers])

  method set_waiting_list x = {< waiting_list = x >}
  method set_payment      x = {< payment      = x >}
  method set_validation   x = {< validation   = x >}
  method set_semantics    x = {< semantics    = x >}
  method set_grant_tokens x = {< grant_tokens = x >}
  method set_read         x = {< read         = x >}

end

type access = [`Viewers|`Registered|`Managers]

class editable_wall ?(wall=default_wall) () = object   
  val read = wall # read
  method read = (read : access)
  method set_read x = {< read = x >}
  val post = wall # post
  method post = (post : access)
  method set_post x = {< post = x >}
end

class editable_album ?(album=default_album) () = object
  val read = album # read
  method read = (read : access)
  method set_read x = {< read = x >}
  val post = album # post
  method post = (post : access)
  method set_post x = {< post = x >}
end

class editable_folder ?(folder=default_folder) () = object
  val read = folder # read
  method read = (read : access)
  method set_read x = {< read = x >}
  val post = folder # post
  method post = (post : access)
  method set_post x = {< post = x >}
end

class editable_votes ?(votes=default_votes) () = object
  val read = votes # read
  method read = (read : access)
  method set_read x = {< read = x >}
  val vote = votes # vote
  method vote = (vote : access)
  method set_vote x = {< vote = x >}
end

let default_group  = new editable_group  ()
let default_wall   = new editable_wall   () 
let default_album  = new editable_album  () 
let default_folder = new editable_folder ()
let default_votes  = new editable_votes  ()

class editable_config config = object (self)

  val group  = BatOption.map (fun group  -> new editable_group  ~group  ()) (config # group)
  val wall   = BatOption.map (fun wall   -> new editable_wall   ~wall   ()) (config # wall)
  val album  = BatOption.map (fun album  -> new editable_album  ~album  ()) (config # album) 
  val folder = BatOption.map (fun folder -> new editable_folder ~folder ()) (config # folder)
  val votes  = BatOption.map (fun votes  -> new editable_votes  ~votes  ()) (config # votes)

  method group  = group
  method votes  = votes
  method wall   = wall
  method album  = album
  method folder = folder

  method edit_group  f = {< group  = Some (f (BatOption.default default_group  group )) >}
  method edit_wall   f = {< wall   = Some (f (BatOption.default default_wall   wall  )) >}
  method edit_album  f = {< album  = Some (f (BatOption.default default_album  album )) >}
  method edit_folder f = {< folder = Some (f (BatOption.default default_folder folder)) >}
  method edit_votes  f = {< votes  = Some (f (BatOption.default default_votes  votes )) >}

  method apply : Diff.t -> 'a = function 

    | `NoGroup -> {< group = None >}
    | `Group_WaitingList x -> self # edit_group (fun g -> g # set_waiting_list x)
    | `Group_Payment     x -> self # edit_group (fun g -> g # set_payment      x)
    | `Group_Validation  x -> self # edit_group (fun g -> g # set_validation   x)
    | `Group_PublicList  x -> self 
    | `Group_Semantics   x -> self # edit_group (fun g -> g # set_semantics    x)
    | `Group_GrantTokens x -> self # edit_group (fun g -> g # set_grant_tokens x) 
    | `Group_Read        x -> self # edit_group (fun g -> g # set_read         x)

    | `NoWall -> {< wall = None >}
    | `Wall_Hidden x -> self 
    | `Wall_Read   x -> self # edit_wall (fun w -> w # set_read x)
    | `Wall_Write  x -> self # edit_wall (fun w -> w # set_post x)

    | `NoAlbum -> {< album = None >}
    | `Album_Hidden x -> self
    | `Album_Read   x -> self # edit_album (fun a -> a # set_read x)
    | `Album_Write  x -> self # edit_album (fun a -> a # set_post x)

    | `NoFolder -> {< folder = None >}
    | `Folder_Hidden x -> self
    | `Folder_Read   x -> self # edit_folder (fun f -> f # set_read x)
    | `Folder_Write  x -> self # edit_folder (fun f -> f # set_post x)

    | `NoVotes -> {< votes = None >}
    | `Votes_Read x -> self # edit_votes (fun v -> v # set_read x)
    | `Votes_Vote x -> self # edit_votes (fun v -> v # set_vote x)    
    
end

let apply_diff config list = 
  let result = 
    List.fold_left
      (fun config diff -> config # apply diff) (new editable_config config) list
  in 
  ( result :> t )
