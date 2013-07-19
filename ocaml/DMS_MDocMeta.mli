(* © 2013 RunOrg *)

type 'relation t

module Field : sig
  type t 
  val to_string : t -> string
  val of_string : string -> t
end

module FieldType : sig 
  type t = 
    [ `TextShort
    | `TextLong
    | `AtomOne  of IAtom.Nature.t
    | `AtomMany of IAtom.Nature.t
    | `PickOne  of (string * O.i18n) list
    | `PickMany of (string * O.i18n) list
    | `Date
    ]
end 

val fields : 
     'any IInstance.id
  -> (#O.ctx, (Field.t * < label : O.i18n ; kind : FieldType.t >) list) Ohm.Run.t

module Data : sig
  type t = (Field.t,Ohm.Json.t) BatMap.t
end

module Search : sig
  val by_atom : 
       ?start:DMS_IDocument.t 
    -> count:int 
    -> IAtom.t 
    -> (#O.ctx, DMS_IDocument.t list * DMS_IDocument.t option) Ohm.Run.t
end

module Get : sig
  val id   : 'any t -> 'any DMS_IDocument.id 
  val data : [<`View|`Admin] t -> Data.t 
end

module Set : sig
  val data : Data.t -> [`Admin] t -> 'any MActor.t -> (#O.ctx, unit) Ohm.Run.t
end 

val get : 'rel DMS_IDocument.id -> (#O.ctx, 'rel t) Ohm.Run.t
