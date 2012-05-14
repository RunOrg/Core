(* © 2012 RunOrg *)

open Ohm
open Ohm.Template

module Loader = MModel.Template.MakeLoader(struct let from = "access-flag" end) 

type access = 
  [ `Entity of [ `Admin | `Invite | `Registered | `Normal | `Public ] 
  | `EntityPage of [ `Admin | `Registered | `Normal | `Public ]
  | `Page of [ `Admin | `Normal | `Public ]
  | `Block of [ `Admin | `Normal | `Public ] 
  ]

let icon = function
  | `Entity     `Admin 
  | `EntityPage `Admin
  | `Page       `Admin
  | `Block      `Admin -> VIcon.flag_red
  | `Entity     `Invite  -> VIcon.flag_blue
  | `Entity     `Registered
  | `EntityPage `Registered  -> VIcon.flag_purple
  | `Entity     `Normal
  | `EntityPage `Normal
  | `Page       `Normal
  | `Block      `Normal -> VIcon.flag_orange
  | `Entity     `Public
  | `EntityPage `Public
  | `Page       `Public
  | `Block      `Public -> VIcon.flag_green

let label = function
  | `Entity     `Admin
  | `EntityPage `Admin
  | `Page       `Admin
  | `Block      `Admin -> `label "access.flag.admin" 
  | `Entity     `Invite -> `label "access.flag.invite"
  | `Entity     `Registered 
  | `EntityPage `Registered -> `label "access.flag.registered"
  | `Entity     `Normal
  | `EntityPage `Normal
  | `Page       `Normal
  | `Block      `Normal -> `label "access.flag.normal"
  | `Entity     `Public
  | `EntityPage `Public
  | `Page       `Public
  | `Block      `Public -> `label "access.flag.public"

module Flag = Loader.Html(struct
  type t = access
  let source  _ = "flag"
  let mapping _ = [
    "title", Mk.trad label ;
    "flag",  Mk.esc  icon 
  ]
end) 

module FlagRight = Loader.Html(struct
  type t = access
  let source  _ = "flag-right"
  let mapping _ = [
    "title", Mk.trad label ;
    "flag",  Mk.esc  icon 
  ]
end) 

let render = function
  | None        -> (fun i18n vctx -> vctx) 
  | Some access -> Flag.render access

let render_right = function
  | None        -> (fun i18n vctx -> vctx) 
  | Some access -> FlagRight.render access
