(* © 2013 RunOrg *)

module Field : Ohm.Fmt.FMT with type t = 
  <
    label   : string ;    
    explain : string option ;
    edit    : [ `textarea | `date | `longtext | `hide | `picture ] ;
    valid   : [ `required | `max of int ] list ;
    mean    : [ `description | `date | `enddate | `location | `picture | `summary ] option 
  >

include Ohm.Fmt.FMT with type t = (string * Field.t) list

val default : t

module Diff : Ohm.Fmt.FMT with type t = 
  [ `Remove of string
  | `Move of string * string option 
  | `Add of string * Field.t 
  ]

val names : Diff.t -> (string * string) list

val apply_diff : t -> Diff.t list -> t
