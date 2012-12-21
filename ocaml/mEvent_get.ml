(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module E    = MEvent_core
module Can  = MEvent_can
module Data = MEvent_data

(* Primary properties *)

let id t = Can.id t
let draft t = (Can.data t).E.draft
let vision t = (Can.data t).E.vision
let name t = (Can.data t).E.name
let picture t = BatOption.map IFile.Assert.get_pic (Can.data t).E.pic
let date t = (Can.data t).E.date
let group t = (Can.data t).E.gid
let iid t = (Can.data t).E.iid
let template t = (Can.data t).E.tid
let admins t = MAccess.delegates (Can.data t).E.admins

(* Helper properties *)

let public t = not (draft t) && vision t = `Public

let status t = 
  if draft t then Some `Draft else 
    match vision t with 
      | `Private -> Some `Secret
      | `Normal  -> None
      | `Public  -> Some `Website 

let data t = 
  Data.get (id t)

let fullname t = 
  BatOption.default (AdLib.get `Event_Unnamed) (BatOption.map return (name t))
