(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open Ohm.Util
open BatPervasives

module Loader = MModel.Template.MakeLoader(struct let from = "access" end)

module Autocomplete = Loader.Html(struct
  type t = <
    name : I18n.text ;
    kind : MEntityKind.t ;
    pic  : string 
  > ;;
  let source  _ = "autocomplete"
  let mapping _ = [
    "name", Mk.trad (#name) ;
    "kind", Mk.trad (#kind |- VLabel.of_entity_kind `single) ;
    "pic",  Mk.esc  (#pic) 
  ]
end)
