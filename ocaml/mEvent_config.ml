(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

include Fmt.Make(struct
  type json t = <
    group_validation "gv" : [`Manual  "m" | `None       "n"                ] option ;
    group_read       "gr" : [`Viewers "v" | `Registered "r" | `Managers "m"] option ;
    collab_read      "cr" : [`Viewers "v" | `Registered "r" | `Managers "m"] option ;
    collab_write     "cw" : [`Viewers "v" | `Registered "r" | `Managers "m"] option 
  > 
end) 

let default = object
  method group_validation = None
  method group_read = None
  method collab_read = None
  method collab_write = None
end

module Diff = Fmt.Make(struct
  type json t = 
    [ `Group_Validation "gv" of [`Manual  "m" | `None       "n"                ]
    | `Group_Read       "gr" of [`Viewers "v" | `Registered "r" | `Managers "m"] 
    | `Collab_Read      "cr" of [`Viewers "v" | `Registered "r" | `Managers "m"] 
    | `Collab_Write     "cw" of [`Viewers "v" | `Registered "r" | `Managers "m"] 
    ]
end) 

let apply_one t diff = object
  val diff = diff
  val t = t
  method group_validation = 
    match diff with `Group_Validation x -> Some x | _ -> t # group_validation 
  method group_read = 
    match diff with `Group_Read x -> Some x | _ -> t # group_read
  method collab_read = 
    match diff with `Collab_Read x -> Some x | _ -> t # collab_read
  method collab_write = 
    match diff with `Collab_Write x -> Some x | _ -> t # collab_write
end

let apply diffs t = List.fold_left apply_one t diffs

type 'a config = ITemplate.Event.t -> t -> 'a

let group_validation etid t = 
  match t # group_validation with Some x -> x | None -> `Manual

let group_read etid t = 
  match t # group_read with Some x -> x | None -> `Viewers

let collab_read etid t = 
  match t # collab_read with Some x -> x | None -> `Viewers

let collab_write etid t = 
  match t # collab_write with Some x -> x | None -> `Viewers

