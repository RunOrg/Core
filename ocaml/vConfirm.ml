(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open Ohm.Util
open BatPervasives

module Loader = MModel.Template.MakeLoader(struct let from = "confirm" end)

module VConfirm = Loader.Html(struct
  type t = <
    question : I18n.text ;
    yes :      string 
  >
  let source  _ = "confirm"
  let mapping _ = [
    "question", Mk.trad (#question) ;
    "yes",      Mk.text (#yes |- Js.runFromServer |- JsBase.to_event)
  ]
end)

let ask question yes =
  VConfirm.render (object
    method question = question
    method yes      = yes
  end)
