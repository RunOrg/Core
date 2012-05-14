(* © 2012 Runorg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

module Float = Fmt.Float
module PUser = IUser
module PInstance = IInstance

module MyDB = MModel.FileDB
module Design = struct
  module Database = MyDB
  let name = "file"
end

module Kind = Fmt.Make(struct
  type json t = 
    [ `Temp    "t"
    | `Doc     "d"
    | `Extern  "e"
    | `Picture "p"
    | `Image   "i"
    ]
end)

module VersionData = Fmt.Make(struct
  module Float = Fmt.Float
  type json t = <
    name : string ;
    size : Float.t 
  > 
end)

module MFile = Fmt.Make(struct
  module IUser = IUser
  module IInstance = IInstance
  module IItem = IItem
  type json t = <
    t        : MType.t ;
    k        : Kind.t ;
    usr      : IUser.t ;
    ins      : IInstance.t option ;
    key      : Id.t ;
   ?item     : IItem.t option ;
   ?name     : string option = Some "untitled.txt" ;
    versions : (string * VersionData.t) assoc 
  > 
end)

module MyTable = CouchDB.Table(MyDB)(IFile)(MFile)

include MFile

type version = 
  [ `Original
  | `File
  | `Large
  | `Small ]

let string_of_version = function
  | `Original -> "o"
  | `File     -> "f"
  | `Large    -> "l"
  | `Small    -> "s"

let original = string_of_version `Original
let small    = string_of_version `Small
let large    = string_of_version `Large
let file     = string_of_version `File
