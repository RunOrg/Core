(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Data = struct
  type t = {
    theme : string ;
    name  : string ;
  } 
end

module IdMap = Map.Make(IWhite) 

let items = IdMap.empty |> List.fold_right (fun (k,v) -> IdMap.add k v) [
  IWhite.loi1901, Data.({
    theme = "white" ;
    name  = "Loi 1901"
  })
]

let get id = 
  try return $ Some (IdMap.find id items) with Not_found -> return None 

let theme t = t.Data.theme
let name  t = t.Data.name
