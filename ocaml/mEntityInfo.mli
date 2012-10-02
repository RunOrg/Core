(* © 2012 RunOrg *)

module Format : Ohm.Fmt.FMT with type t = 
  [ `text
  | `longtext
  | `date
  | `location
  | `link
  ]

include Ohm.Fmt.FMT with type t = 
  (string * <
     section : string ;
     items   : (string * <
       label  : string option ;
       fields : (string * <
         field  : string ;
         format : Format.t
       >) list
     >) list
   >) list

val default : t

module Diff : Ohm.Fmt.FMT with type t = 
  [ `DelSection of string
  | `DelItem    of string * string
  | `DelField   of string * string * string
  | `AddSection of string * string
  | `AddItem    of string * string * string option
  | `AddField   of string * string * string * string * Format.t
  | `MovSection of string * string option
  | `MovItem    of string * string * string option
  | `MovField   of string * string * string * string option
  ]

val names : Diff.t -> (string * string) list

val apply_diff : t -> Diff.t list -> t
