(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

type t = 
  [ `Private
  | `Website
  | `Draft
  | `Member  of AdLib.gender 
  | `Admin   of AdLib.gender
  | `Visitor of AdLib.gender
  ] 

let css = function
  | `Private -> "-private"
  | `Website -> "-website"
  | `Draft   -> "-draft"
  | `Member  _ -> "-member"
  | `Admin   _ -> "-admin"
  | `Visitor _ -> "-visitor"

let label = function
  | `Private -> `Status_Private
  | `Website -> `Status_Website
  | `Draft   -> `Status_Draft
  | `Member  g -> `Status_Member  g 
  | `Admin   g -> `Status_Admin   g
  | `Visitor g -> `Status_Visitor g
