(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open Ohm.Template
open BatPervasives

module Loader = MModel.Template.MakeLoader(struct let from = "field" end)

type field = <
  id : Id.t ;
  name : string
> ;;

let mapping = [
  "id",   Mk.esc (fun x -> Id.str (x # id)) ;
  "name", Mk.esc (#name) 
]

module Textarea = Loader.Html(struct
  type t = field
  let source  _ = "textarea"
  let mapping _ = mapping
end)

module Checkbox = Loader.Html(struct
  type t = field
  let source  _ = "checkbox"
  let mapping _ = mapping
end)

module ShortText = Loader.Html(struct
  type t = field
  let source  _ = "short_text"
  let mapping _ = mapping
end)

module LongText = Loader.Html(struct
  type t = field
  let source  _ = "long_text"
  let mapping _ = mapping   
end)

module Date = struct
  let render field i18n ctx = 
    ctx
    |> View.Context.add_js_code (Js.datepicker (Id.sel (field # id)) ~lang:(I18n.language i18n) ~ancient:false) 
    |> ShortText.render field i18n
end

type pick_item =  <
  name : string ;
  id : Id.t ;
  value : int ;
  label : I18n.text 
> ;;

let pick_mapping = [    
  "name",     Mk.esc (#name) ;
  "id",       Mk.esc (fun x -> Id.str x # id) ;
  "value",    Mk.esc (fun x -> string_of_int x # value) ;
  "label",    Mk.trad (#label)
] 

module PickOneItem = Loader.Html(struct
  type t = pick_item
  let source  _ = "pickOne-item"
  let mapping _ = pick_mapping
end)

module PickOne = Loader.Html(struct
  type t = PickOneItem.t list
  let source  _ = "pickOne"
  let mapping l = [
    "list", Mk.list identity (PickOneItem.template l)
  ]
end)
    
module PickManyItem = Loader.Html(struct
  type t = pick_item
  let source  _ = "pickMany-item"
  let mapping _ = pick_mapping
end)

module PickMany = Loader.Html(struct
  type t = PickManyItem.t list
  let source  _ = "pickMany"
  let mapping l = [
    "list", Mk.list identity (PickManyItem.template l)
  ]
end)

module VField = Loader.Html(struct
  type t = <
    label : View.html ;
    input : View.html ;
    error : View.html ; 
    required : bool ;
    help : I18n.text option 
  > ;;
  let source  _ = "field"
  let mapping _ = [
    "label",    Mk.html (#label) ;
    "input",    Mk.html (#input) ;
    "error",    Mk.html (#error) ;
    "required", Mk.str (fun x -> if x # required then "required" else "") ;
    "help",     Mk.trad (#help |- BatOption.default (`label ""))
  ]
end)

module Fields = Loader.Html(struct
  type t = VField.t list
  let source  _ = "fields"
  let mapping l = [
    "list", Mk.list identity (VField.template l)
  ]
end)
