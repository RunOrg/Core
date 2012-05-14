(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

open CDashboard_common

module Members    = CDashboard_members
module Activities = CDashboard_activities


(* Per-kind construction of dashboard contents *)

let contents ctx kind = 
  let! dynamic_definitions = ohm (
    match kind with 
      | `DashMembers    -> Members.dynamic    ~ctx 
      | `DashActivities -> Activities.dynamic ~ctx
  ) in
  return (fun callback -> 
    let! top, dynamic = dynamic_definitions in
    callback (top, dynamic)
  )
  
let title = function
  | `DashMembers -> "dashboard.title.members"
  | `DashActivities -> "dashboard.title.activities"

let access = function
  | `DashMembers    -> `Page `Public
  | `DashActivities -> `Page `Public

(* Rendering a dashboard *)

let render i18n title (top,elements) access = 
  
  O.Box.leaf begin fun input url -> 

    let top      = BatOption.map (fun e -> e input url) top in 
    let elements = List.map      (fun e -> e input url) elements in

    let data = object
      method title    = title
      method elements = elements
      method access   = access 
      method top      = top 
    end in
  
    return (VDashboard.Index.render data i18n)
  end

(* Constructing dashboard contents *)

let home_box kind ~ctx =
  let! elements_definition = ohm (contents ctx kind) in
  return begin 
    let! elements = elements_definition in
    let title  = `label (title kind) in 
    let access = Some (access kind) in 
    render (ctx # i18n) title elements access
  end
