(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open Ohm.Template
open BatPervasives

let load name = MModel.Template.load "splash" name
let jsload name = MModel.Template.jsload "splash" name

module Loader = MModel.Template.MakeLoader(struct let from = "splash" end)

module Newsletter = struct

  let _success = 
    let _fr = load "newsletter-success-fr" [ 
      "email", Mk.esc (#email) 
    ] `Html in    
    function `Fr -> _fr

  let success email i18n ctx = 
    to_html
      (_success (I18n.language i18n)) 
      (object method email = email end)
      i18n ctx

end

module Contact = Loader.Html(struct
  type t = unit
  let source    = function `Fr -> "contact-fr"
  let mapping _ = []
end)

module CguCgv = Loader.Html(struct
  type t = unit
  let source    = function `Fr -> "cgu-cgv-fr"
  let mapping _ = []
end)

