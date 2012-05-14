(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open Ohm.Universal
open BatPervasives

module What = Fmt.Make(struct
  module IFeed = IFeed
  type json t =
    [ `Feed "f" of IFeed.t ]
end)

type what = What.t

module Data = struct
  module T = struct
    module IAvatar = IAvatar
    type json t = {
      what : What.t ;
      who  : IAvatar.t 
    }
  end
  include T
  include Fmt.Extend(T)
end

module MyDB = CouchDB.Convenience.Database(struct let db = O.db "block" end)
module MyTable = CouchDB.Table(MyDB)(Id)(Data)

module Design = struct
  module Database = MyDB
  let name = "block"
end

module FindKey = Fmt.Make(struct
  module IAvatar = IAvatar
  type json t = What.t * IAvatar.t
end)

module Find = CouchDB.MapView(struct
  module Key = FindKey
  module Value = Fmt.Unit
  module Design = Design
  let name = "find"
  let map  = "emit([doc.what,doc.who],null)"  
end)

let is_blocked avatar what =
  let! list = ohm $ Find.by_key (what,IAvatar.decay avatar) in
  return (list <> [])

let block avatar what = 
  let! is_blocked = ohm $ is_blocked avatar what in
  if is_blocked then return () else
    MyTable.transaction (Id.gen ())
      (MyTable.insert Data.({ what = what ; who = IAvatar.decay avatar })) |> Run.map ignore

let unblock avatar what =   

  let! list = ohm $ Find.by_key (what,IAvatar.decay avatar) in

  let! _    = ohm $
    Run.list_map (fun item ->
      MyTable.transaction (item # id) MyTable.remove
    ) list
  in

  return ()

module ByWhat = CouchDB.MapView(struct
  module Key = What
  module Value = IAvatar
  module Design = Design
  let name = "by_what"
  let map  = "emit(doc.what,doc.who)"
end)

let all_blockers what = 
  let! list = ohm $ ByWhat.by_key what in
  let addset set item = BatPSet.add (item # value) set in
  return $
    List.fold_left addset BatPSet.empty list
