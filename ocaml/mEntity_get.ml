(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

module E = MEntity_core

type 'a t = 'a MEntity_can.t

let get = MEntity_can.data 
let id  = MEntity_can.id

let status t = 
  let e = get t in 
  if e.E.draft then Some `Draft else 
    if e.E.public then Some `Website else
      match MAccess.summarize e.E.view with 
	| `Admin  -> Some `Secret
	| `Member -> None
	
let deleted       t = (get t).E.deleted 
  
let inactive      t = (get t).E.deleted <> None || (get t).E.draft
  
let name          t = (get t).E.name
let config        t = (get t).E.config
let date          t = (get t).E.date
let end_date      t = (get t).E.end_date

let real_access   t = 
  let config = config t in
  let e = get t in
  if e.E.public then `Public else
    let access = MAccess.summarize e.E.view in
    if MEntityConfig.group e.E.template config <> None then 
      match access with 
	| `Admin -> `Private
	| any    -> `Normal
    else
      `Normal

let grants t = 
  let e = get t in 
  e.E.kind = `Group 

let group t = (get t).E.group
      	
let instance      t = (get t).E.instance
let template      t = (get t).E.template
let template_name t = `label (PreConfig_Template.name (template t))

let kind          t = (get t).E.kind
let draft         t = (get t).E.draft
let public        t = (get t).E.public

let picture       t = (get t).E.picture
       
let summary       t = let s = (get t).E.summary in
		      if s = "" then template_name t else `text s
 
let admin         t = (get t).E.admin
