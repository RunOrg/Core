(* © 2013 RunOrg *)

type t = 
  [ `TextShort
  | `TextLong
  | `PickOne  of (string * O.i18n) list
  | `PickMany of (string * O.i18n) list
  | `Date
  ]
