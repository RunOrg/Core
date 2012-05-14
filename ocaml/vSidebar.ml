(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open Ohm.Util
open BatPervasives

module Loader = MModel.Template.MakeLoader(struct let from = "sidebar" end)

module Subsection = Loader.Html(struct
  type t = <
    selected : bool ;
    label    : I18n.text ;
    icon     : string ;
    url      : string
  > ;;
  let source  _ = "index/sections/contents"
  let mapping _ = [ 
    "label",    Mk.trad (#label) ;
    "icon",     Mk.esc  (#icon) ;
    "url",      Mk.esc  (#url) ;
    "selected", Mk.str  (fun x -> if x # selected then " -selected" else "") ;
  ]
end)

module Section = Loader.Html(struct
  type t = <
    selected : bool ;
    opened   : bool ;    
    admin    : bool ;
    url      : string ;
    label    : I18n.text ;
    contents : Subsection.t list 
  > ;;
  let source  _ = "index/sections"
  let mapping l = [
    "label",    Mk.trad (#label) ;
    "url",      Mk.esc  (#url) ;
    "selected", Mk.str  (fun x -> if x # selected then "-selected" else "") ;
    "open",     Mk.str  (fun x -> if x # opened then "-open" else "") ;
    "admin",    Mk.str  (fun x -> if x # admin then "-admin" else "") ;
    "contents", Mk.list (#contents) (Subsection.template l) ;
  ]    
end)

module Index = Loader.Html(struct
  type t = Section.t list
  let source  _ = "index"
  let mapping l = [
    "sections", Mk.list identity (Section.template l)
  ] 
end)
