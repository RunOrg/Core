(* © 2012 RunOrg *)

module MyDB : Ohm.CouchDB.DATABASE
module Design : Ohm.CouchDB.DESIGN
module MyTable : Ohm.CouchDB.TABLE with type id = IInstance.t and type elt = MInstance_data.t

val get_raw : 'any IInstance.id -> MInstance_data.t option O.run
