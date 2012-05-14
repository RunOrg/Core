(* © 2012 MRunOrg *)

open Ohm
open Ohm.Util
open Ohm.Universal
open BatPervasives

module Data = struct
  module T = struct
    module IVertical = IVertical
    type json t = {
      vertical : IVertical.t ;
      name     : string ;
      desc     : string ;
      key      : string 
    }
  end
  include T
  include Fmt.Extend(T)
end

module MyDB = MModel.Register(struct let db = "funnel" end)
module MyTable = CouchDB.Table(MyDB)(IFunnel)(Data)

let default = Data.({
  vertical = IVertical.standard ;
  name     = "" ;
  desc     = "" ;
  key      = "" 
})

let set id update = 

  let update id = 
    let! data = ohm $ MyTable.get id in
    return ((), `put (match data with
      | None      -> update default
      | Some data -> update data
    ))
  in

  let! _ = ohm (MyTable.transaction id update) in

  return ()
  
let set_vertical id vertical = 
  set id (fun data -> Data.({ data with vertical }))

let set_info id name desc key = 
  set id (fun data -> Data.({ data with name ; desc ; key }))

let get id = 
  MyTable.get id
  
