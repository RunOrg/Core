(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let lock_life = 60.
let expire_time = 60.

module Item = struct
  module T = struct
    type json t = {
      time : float ;
      lock : float option ;
    }
  end
  include T 
  include Fmt.Extend(T)

  let lock   now doc = { doc with lock = Some now }
  let unlock now doc = { time = now ; lock = None }
    
  let never = { time = 0.0 ; lock = None } 

end
 
let locked now doc = match doc.Item.lock with 
  | None -> false
  | Some lock -> lock +. lock_life > now 

let recent now doc = doc.Item.time +. expire_time > now

include CouchDB.Convenience.Table(struct let db = O.db "news-lock" end)(IUser)(Item)

let grab id = 
  let! now = ohmctx (#time) in
  Tbl.transact id begin fun item ->
    let item = match item with None -> Item.never | Some item -> item in 
    let recent = recent now item and locked = locked now item in    
    return (
      (object method last = item.Item.time method recent = recent method locked = locked end),
      if locked then `keep else `put (Item.lock now item)
    )
  end 

let release id = 
  let! now = ohmctx (#time) in
  Tbl.update id (Item.unlock now) 
