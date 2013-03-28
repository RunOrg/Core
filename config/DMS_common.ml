(* © 2013 RunOrg *)

open Common

type fieldtype = 
  [ `TextShort
  | `TextLong
  | `AtomOne  of Atom.nature
  | `AtomMany of Atom.nature
  | `PickOne  of (string * adlib) list
  | `PickMany of (string * adlib) list
  | `Date
  ]

type field = {
  key   : string ; 
  kind  : fieldtype ;
  label : adlib ;  
}

let fields = ref []

let field key label kind = 
  fields := { key ; label ; kind } :: !fields ;
  key 

let fieldsets : (string * string list) list ref = ref []

let fieldset name keys = 
  fieldsets := (name, keys) :: !fieldsets
   
