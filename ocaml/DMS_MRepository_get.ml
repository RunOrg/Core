(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module E    = DMS_MRepository_core
module Can  = DMS_MRepository_can

(* Primary properties *)

let id t = Can.id t
let vision t = (Can.data t).E.vision
let name t = (Can.data t).E.name
let iid t = (Can.data t).E.iid
let admins t = MAccess.delegates (Can.data t).E.admins
let upload t = (Can.data t).E.upload
let remove t = (Can.data t).E.remove
let detail t = (Can.data t).E.detail

(* Helper properties *)

let uploaders t = match upload t with 
  | `List aids -> aids
  | `Viewers -> []

