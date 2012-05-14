(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

let get size dflt img = 
  match img with None -> return dflt | Some id ->
    MFile.Url.get id size |> Run.map (BatOption.default dflt)

let small img = get `Small "/public/img/404_img_small.png" img
let large img = get `Large "/public/img/404_img_large.png" img
