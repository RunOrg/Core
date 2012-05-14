(* © 2012 RunOrg *)

open Ohm
open Ohm.Template

module Loader = MModel.Template.MakeLoader(struct let from = "forbidden" end)

module VForbidden = Loader.Html(struct
  type t = unit
  let source = function `Fr -> "index-fr"
  let mapping _ = []
end)

let render = VForbidden.render ()
