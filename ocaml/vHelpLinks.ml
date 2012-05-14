(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open Ohm.Template

module Loader = MModel.Template.MakeLoader(struct let from = "helpLinks" end)

module Link = Loader.Html(struct
  type t = <
    url   : string ;
    label : string 
  > ;;
  let source  _ = "link"
  let mapping _ = [
    "url",   Mk.esc (#url) ;
    "title", Mk.esc (#label) 
  ]
end)

type box = <
  links : Link.t list ;
  more  : string
>

let box_mapping l = [
  "list", Mk.list (#links) (Link.template l) ;
  "more",  Mk.esc  (#more) 
]

module LeftBox = Loader.Html(struct
  type t = box
  let source  _ = "box-left"
  let mapping l = box_mapping l
end)

module RightBox = Loader.Html(struct
  type t = box
  let source  _ = "box-right"
  let mapping l = box_mapping l 
end)

