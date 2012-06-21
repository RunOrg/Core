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
  ] 

let css = function
  | `Secret  -> "-secret"
  | `Website -> "-website"
  | `Draft   -> "-draft"
  | `Member  _ -> "-member"
  | `Admin   _ -> "-admin"
  | `Visitor _ -> "-visitor"

let label = function
  | `Secret  -> `Status_Secret
  | `Website -> `Status_Website
  | `Draft   -> `Status_Draft
  | `Member  g -> `Status_Member  g 
  | `Admin   g -> `Status_Admin   g
  | `Visitor g -> `Status_Visitor g
