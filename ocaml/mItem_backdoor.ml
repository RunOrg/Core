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
  let! data_opt = ohm $ MyTable.get itid in
  return (BatOption.map (Types.bot_item_of_data itid) data_opt)
