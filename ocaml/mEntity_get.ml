(* © 2012 MRunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

module E = MEntity_core

type 'a t = 'a MEntity_can.t

let get = MEntity_can.data 
let id  = MEntity_can.id

let status t = 
  if (get t).E.deleted <> None then `Delete else
    if (get t).E.draft then `Draft else
      `Active
	
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
    if config # group <> None then 
      match access with 
	| `Admin -> `Invite
	| any    -> any 
    else
      access

let grants t = 
  let config = config t in 
  match config # group with None -> false | Some config -> 
    match config # grant_tokens with 
      | `yes -> true
      | `no  -> false

let on_add t = 
  let config = config t in 
  match config # group with None -> `ignore | Some config ->
    match config # semantics with 
      | `group -> `add
      | `event -> `invite

let group t = (get t).E.group
      	
let instance      t = (get t).E.instance
let template      t = (get t).E.template
let template_name t = match MVertical.Template.get (template t) with
  | None      -> `label ""
  | Some tmpl -> `label (tmpl # name)

let kind          t = (get t).E.kind
let draft         t = (get t).E.draft
let public        t = (get t).E.public

let picture       t = (get t).E.picture
       
let summary       t = let s = (get t).E.summary in
		      if s = "" then template_name t else `text s
 
let admin         t = (get t).E.admin
