(* © 2012 Runorg *)

open Ohm
open Ohm.Util
open Ohm.Template
open BatPervasives

module Loader = MModel.Template.MakeLoader(struct let from = "payment" end)

module Error = Loader.Html(struct
  type t = <
    asso : string ;
    back : string 
  > ;;
  let source = function `Fr -> "error-fr"
  let mapping _ = [
    "asso", Mk.esc (#asso) ;
    "back", Mk.esc (#back) 
  ]
end)
  
module Accept = Loader.Html(struct
  type t = <
    asso    : string ;
    confirm : string ;
    cancel  : string ;
    amount  : int 
  > ;;
  let source = function `Fr -> "accept-fr"
  let mapping _ = [
    "asso",    Mk.esc  (#asso) ;
    "cancel",  Mk.esc  (#cancel) ;
    "amount",  Mk.esc  (fun x -> Printf.sprintf "%.02f" (float_of_int x # amount /. 100.)) ;
    "confirm", Mk.text (fun x -> JsBase.to_event (Js.runFromServer ~disable:true (x # confirm)))
  ]
end)

module Thanks = Loader.Html(struct
  type t = <
    asso     : string ;
    continue : string ;
    amount   : int 
  > ;;
  let source = function `Fr -> "thanks-fr"
  let mapping _ = [
    "asso",     Mk.esc  (#asso) ;
    "continue", Mk.esc  (#continue) ;
    "amount",   Mk.esc  (fun x -> Printf.sprintf "%.02f" (float_of_int x # amount /. 100.)) ;
  ]
end)
