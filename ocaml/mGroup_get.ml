(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module E    = MGroup_core
module Can  = MGroup_can

(* Primary properties *)

let id t = Can.id t
let vision t = (Can.data t).E.vision
let name t = (Can.data t).E.name
let group t = (Can.data t).E.gid
let iid t = (Can.data t).E.iid
let template t = (Can.data t).E.tid
let admins t = IDelegation.avatars (Can.data t).E.admins

(* Helper properties *)

let public t = vision t = `Public

let status t = 
  match vision t with 
    | `Private -> Some `Secret
    | `Normal  -> None
    | `Public  -> Some `Website 

let fullname t = 
  match name t with 
    | Some n -> TextOrAdlib.to_string n
    | None   -> AdLib.get `Group_Unnamed

let is_admin t = 
  let  namer = MPreConfigNamer.load (iid t) in
  let! admin_gid = ohm $ MPreConfigNamer.group IGroup.admin namer in 
  return (IGroup.decay (id t) = admin_gid) 

let is_all_members t = 
  let  namer = MPreConfigNamer.load (iid t) in
  let! members_gid = ohm $ MPreConfigNamer.group IGroup.members namer in 
  return (IGroup.decay (id t) = members_gid) 
