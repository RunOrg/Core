(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

include Fmt.Make(struct
  type json t = <
    group_validation "gv" : [`Manual  "m" | `None       "n"                ] option ;
    group_read       "gr" : [`Viewers "v" | `Registered "r" | `Managers "m"] option ;
  > 
end) 

let default = object
  method group_validation = None
  method group_read = None
end

module Diff = Fmt.Make(struct
  type json t = 
    [ `Group_Validation "gv" of [`Manual  "m" | `None       "n"                ]
    | `Group_Read       "gr" of [`Viewers "v" | `Registered "r" | `Managers "m"] 
    ]
end) 

let apply_one t diff = object
  val diff = diff
  val t = t
  method group_validation = 
    match diff with `Group_Validation x -> Some x | _ -> t # group_validation 
  method group_read = 
    match diff with `Group_Read x -> Some x | _ -> t # group_read
end

let apply diffs t = List.fold_left apply_one t diffs

type 'a config = ITemplate.Group.t -> t -> 'a

let group_validation etid t = 
  match t # group_validation with Some x -> x | None -> `Manual

let group_read etid t = 
  match t # group_read with Some x -> x | None -> `Viewers
