(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module MyDB = MModel.Register(struct let db = "user-digest" end) 
module MyUnique = OhmCouchUnique.Make(MyDB)

let get id = MyUnique.get (IUser.to_string id) |> Run.map IDigest.of_id  
let get_if_exists id = MyUnique.get_if_exists (IUser.to_string id)
  |> Run.map (BatOption.map IDigest.of_id) 

let reverse did = 
  MyUnique.reverse (IDigest.to_id did) |> Run.map (List.map IUser.of_string)
