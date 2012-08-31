(* © 2012 RunOrg *)

module MFile : Ohm.Fmt.FMT with type t = <
  t        : MType.t ;
  k        : [ `Temp | `Doc | `Extern | `Picture | `Image ] ;
  usr      : IUser.t ;
  ins      : IInstance.t option ;
  key      : Ohm.Id.t ;
  item     : IItem.t option ;
  name     : string option ;
  versions : (string * < name : string ; size : float >) list
> 

module Tbl : Ohm.CouchDB.TABLE with type id = IFile.t and type elt = MFile.t

module Design : Ohm.CouchDB.DESIGN

type version = [ `File | `Original | `Small | `Large ]

val string_of_version : version -> string
val original : string
val small : string
val large : string
val file : string
