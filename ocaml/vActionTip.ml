(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open Ohm.Util
open BatPervasives

module Loader = MModel.Template.MakeLoader(struct let from = "actionTip" end)

module Link = Loader.Html(struct
  type t = <
    url : string ;
    icon : string ;
    title : I18n.text
  > 
  let source  _ = "link"
  let mapping _ = [
    "url",   Mk.esc  (#url) ;
    "icon",  Mk.esc  (#icon) ;
    "title", Mk.trad (#title)
  ]
end)
