(* © 2012 RunOrg *)

open Ohm

let rest path list = path^"/"^(String.concat "/" (List.filter (fun s -> s <> "") list))

