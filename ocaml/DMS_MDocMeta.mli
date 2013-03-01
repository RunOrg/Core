(* © 2013 RunOrg *)

type 'relation t

module Field : sig
  type t 
  val to_string : t -> string
  val of_string : string -> t
end

module FieldType : Ohm.Fmt.FMT with type t = 
  [ `TextShort
  | `TextLong
  | `PickOne  of (string * TextOrAdlib.t) list
  | `PickMany of (string * TextOrAdlib.t) list
  | `Date
  ]

module Data : sig
  type t = (Field.t,Ohm.Json.t) BatPMap.t
end

module Get : sig
  val id   : 'any t -> 'any DMS_IDocument.id 
  val data : [<`View|`Admin] t -> Data.t 
end

module Set : sig
  val data : Data.t -> [`Admin] t -> 'any MActor.t -> (#O.ctx, unit) Ohm.Run.t
end 

val get : 'rel DMS_IDocument.id -> (#O.ctx, 'rel t) Ohm.Run.t
