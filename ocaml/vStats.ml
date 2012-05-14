(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open Ohm.Template

module Loader = MModel.Template.MakeLoader(struct let from = "stats" end)

module ViewItem = Loader.Html(struct
  type t = <
    answer  : I18n.text ;
    count   : int ;
    percent : float ;
  > ;;
  let source  _ = "view/lines"
  let mapping _ = [
    "answer",  Mk.trad (#answer) ;
    "count",   Mk.esc  (fun x -> string_of_int (x # count)) ;
    "percent", Mk.esc  (fun x -> Printf.sprintf "%.2f" (x # percent)) ;
  ] 
end)

module View = Loader.Html(struct
  type t = <
    total : int ;
    lines : ViewItem.t list 
  > ;;
  let source  _ = "view"
  let mapping l = [
    "total", Mk.esc  (fun x -> string_of_int (x # total)) ;
    "lines", Mk.list (#lines) (ViewItem.template l)
  ] 
end)

let render ~total ~stats i18n ctx = 
  let percent = VPercent.compute total in
  View.render(object 
    method total = total 
    method lines = List.map (fun (answer, count) -> (object
      method answer  = answer
      method count   = count
      method percent = percent count
    end)) stats
  end) i18n ctx
