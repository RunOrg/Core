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

module Kind = Fmt.Make(struct
  type json t = [ `Send "s" | `Block "b" ] 
end)

type status = Kind.t

module Data = struct
  module T = struct
    type json t = {
      what     : What.t ;
      who      : IAvatar.t ;
     ?kind "k" : Kind.t = `Block 
    }
  end
  include T
  include Fmt.Extend(T)
end

module MyDB = CouchDB.Convenience.Database(struct let db = O.db "block" end)
module Tbl = CouchDB.Table(MyDB)(Id)(Data)

module Design = struct
  module Database = MyDB
  let name = "block"
end

module FindKey = Fmt.Make(struct
  type json t = ( What.t * IAvatar.t ) 
end)

module Find = CouchDB.MapView(struct
  module Key = FindKey
  module Value = Kind
  module Design = Design
  let name = "find"
  let map  = "emit([doc.what,doc.who],doc.k)"  
end)

let status avatar what = 
  let! list = ohm $ Find.by_key (what,IAvatar.decay avatar) in
  match list with 
    | []     -> return None
    | h :: _ -> return $ Some (h # value)

let set avatar what kind = 
  let! list = ohm $ Find.by_key (what, IAvatar.decay avatar) in
  if list = [] then 
    let! _ = ohm $ Tbl.create Data.({ what ; who = IAvatar.decay avatar ; kind }) in
    return ()
  else 
    Run.list_iter begin fun item -> 
      Tbl.update (item # id) (fun d -> Data.({ d with kind }))
    end list
      
let block avatar what = 
  let! current = ohm $ status avatar what in 
  if current = Some `Block then return () else set avatar what `Block

let unblock avatar what =   
  let! current = ohm $ status avatar what in 
  if current = Some `Send then return () else set avatar what `Send

module ByWhat = CouchDB.MapView(struct
  module Key = What
  module Value = Fmt.Make(struct
    type json t = ( IAvatar.t * Kind.t )
  end)
  module Design = Design
  let name = "by_what"
  let map  = "emit(doc.what,[doc.who,doc.k])"
end)

let all_special what = 
  let! list = ohm $ ByWhat.by_key what in
  let  list = List.map (#value) list in 
  let  block, send = List.partition (fun (_,k) -> k = `Block) list in 
  let  block = List.map fst block in
  let  send  = List.map fst send in 
  return (object
    method block = block 
    method send  = send
  end)
  

