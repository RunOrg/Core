(* © 2013 RunOrg *)

module FieldType : Ohm.Fmt.FMT with type t = 
  [ `Textarea
  | `Date
  | `LongText
  | `Checkbox
  | `PickOne  of TextOrAdlib.t list
  | `PickMany of TextOrAdlib.t list
  ]

type 'a field = <
  name     : 'a ;
  label    : TextOrAdlib.t ;
  edit     : FieldType.t ;
  required : bool  
>

module Simple : Ohm.Fmt.FMT with type t = string field

type profile = 
  [ `Birthdate
  | `Phone    
  | `Cellphone
  | `Address  
  | `Zipcode  
  | `City     
  | `Country  
  | `Gender   
  ]

module Field : Ohm.Fmt.FMT with type t = 
  [ `Local   of string field 
  | `Profile of bool * profile
  | `Import  of bool * IAvatarSet.t * string
  ]

module Flat : sig

  type t = 
    [ `Group   of (IAvatarSet.t * string) field
    | `Profile of profile field
    ]

  val group : bool -> IAvatarSet.t -> string field -> t
  val profile : bool -> profile -> t

  val collapse : t -> unit field

  val dispatch : 
       ([ `Group of (IAvatarSet.t * string) | `Profile of profile ] * Ohm.Json.t) list
    -> < 
      profile : (profile * Ohm.Json.t) list ;
      groups : (IAvatarSet.t * (string * Ohm.Json.t) list) list
    >

end
