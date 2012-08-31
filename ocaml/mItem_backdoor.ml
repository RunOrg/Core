(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open MItem_db

module Types = MItem_types

module CountView = CouchDB.ReduceView(struct
  module Key    = Fmt.Unit
  module Value  = Fmt.Int
  module Design = Design
  let name   = "backdoor-count" 
  let map    = "emit(null,1);"
  let group  = true 
  let level  = None 
  let reduce = "return sum(values);" 
end)

let count () = 
  CountView.reduce_query () |> Run.map begin function
    | ( _, v ) :: _ -> v 
    | _ -> 0
  end
      
let get itid =
  let itid = IItem.decay itid in
  let! data_opt = ohm $ Tbl.get itid in
  return (BatOption.map (Types.bot_item_of_data itid) data_opt)

module InstanceCountView = CouchDB.ReduceView(struct
  module Key    = Fmt.Make(struct type json t = (string * IInstance.t) end)
  module Value  = Fmt.Int
  module Design = Design
  let name = "backdoor-iid-count"
  let map  = "emit([doc.ct.substr(0,6),doc.iid],1)"
  let group = true
  let level = None
  let reduce = "return sum(values);" 
end)

let rec clip yyyy mm = 
  if mm < 0 then clip (yyyy - 1) (mm + 12) else
    if mm >= 12 then clip (yyyy + 1) (mm - 12) else
      Printf.sprintf "%04d%02d" yyyy (mm + 1) 

let active_instances _ ago = 

  let! time = ohmctx (#time) in
  let  date = Unix.gmtime time in
  let  date = Unix.(clip (date.tm_year + 1900) (date.tm_mon - ago)) in
  let  startkey = ( date, IInstance.of_id Id.smallest ) in
  let  endkey   = ( date, IInstance.of_id Id.largest  ) in
  let! list = ohm $ InstanceCountView.reduce_query ~startkey ~endkey ( ) in

  let  totals = List.fold_left (fun map ((_,iid),count) -> 
    let old = try BatPMap.find iid map with Not_found -> 0 in 
    BatPMap.add iid (old + count) map
  ) BatPMap.empty list in 

  let list   = BatPMap.foldi (fun k v acc -> (k,v) :: acc) totals [] in
  let sorted = List.sort (fun (_,a) (_,b) -> compare b a) list in
							  
  return sorted
