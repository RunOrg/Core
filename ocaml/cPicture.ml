(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

let get size dflt pic = 
  match pic with None -> return dflt | Some id ->
    MFile.Url.get id size |> Run.map (BatOption.default dflt)

let small pic = get `Small "/public/img/404_small.png" pic
let large pic = get `Large "/public/img/404_large.png" pic
