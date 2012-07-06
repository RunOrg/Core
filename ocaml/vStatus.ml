(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

type t = 
  [ `Secret
  | `Website
  | `Draft
  | `Member  of AdLib.gender 
  | `Admin   of AdLib.gender
  | `Visitor of AdLib.gender
  | `GroupMember of Ohm.AdLib.gender
  | `Unpaid      of Ohm.AdLib.gender
  | `Declined    of Ohm.AdLib.gender
  | `Invited     of Ohm.AdLib.gender
  | `Pending     of Ohm.AdLib.gender
  ] 

let css = function
  | `Secret  -> "-secret"
  | `Website -> "-website"
  | `Draft   -> "-draft"
  | `Member  _ -> "-member"
  | `Admin   _ -> "-admin"
  | `Visitor _ -> "-visitor"
  | `GroupMember _ -> "-groupMember"
  | `Unpaid      _ -> "-unpaid"
  | `Declined    _ -> "-declined"
  | `Invited     _ -> "-invited"
  | `Pending     _ -> "-pending"

let label = function
  | `Secret  -> `Status_Secret
  | `Website -> `Status_Website
  | `Draft   -> `Status_Draft
  | `Member  g -> `Status_Member  g 
  | `Admin   g -> `Status_Admin   g
  | `Visitor g -> `Status_Visitor g
  | `GroupMember g -> `Status_GroupMember g
  | `Unpaid      g -> `Status_Unpaid g
  | `Declined    g -> `Status_Declined g
  | `Invited     g -> `Status_Invited g
  | `Pending     g -> `Status_Pending g
