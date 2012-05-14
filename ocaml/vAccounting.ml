(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open Ohm.Util
open BatPervasives

module Loader = MModel.Template.MakeLoader(struct let from = "accounting" end)

module Line = Loader.Html(struct
  type t = < 
    details   : I18n.text ;
    who       : string ;
    url       : string ;
    date      : string ;
    amount    : int ;
    direction : [`In|`Out] ;
    canceled  : bool 
  > ;; 
  let source  _ = "page/lines"
  let mapping _ = [
    "details",  Mk.trad  (#details) ;
    "who",      Mk.esc   (#who) ;
    "url",      Mk.esc   (#url) ;
    "date",     Mk.iesc  (#date |- VDate.day_render) ;
    "canceled", Mk.str   (fun x -> if x # canceled then " -canceled" else "") ;
    "out",      Mk.str   (fun x -> if x # direction = `In  then "" else VMoney.print (x # amount)) ;
    "in",       Mk.str   (fun x -> if x # direction = `Out then "" else VMoney.print (x # amount)) ;
  ]
end)

module CreatePage = Loader.Html(struct
  type t = <
    title   : I18n.text ;
    content : I18n.html
  > ;;
  let source  _ = "create-page"
  let mapping _ = [
    "title",   Mk.trad  (#title) ;
    "content", Mk.ihtml (#content) 
  ]
end)
  
module Page = Loader.Html(struct
  type t = <
    new_out   : string ;
    new_in    : string ;
    download  : string ;
    out_total : int ;
    in_total  : int ;
    lines     : Line.t list 
  > ;;
  let source  _ = "page"
  let mapping l = [
    "new-out",   Mk.esc  (#new_out) ;
    "new-in",    Mk.esc  (#new_in) ;
    "download",  Mk.esc  (#download) ;
    "out-total", Mk.esc  (#out_total |- VMoney.print) ;
    "in-total",  Mk.esc  (#in_total  |- VMoney.print) ;
    "lines",     Mk.list (#lines) (Line.template l)
  ]
end)

module TabPage = Loader.Html(struct
  type t = View.html
  let source  _ = "tab-page"
  let mapping _ = [
    "content", Mk.html identity
  ]
end)

module DetailPage_Cancel = Loader.Html(struct
  type t = string  ;;
  let source  _ = "detail-page/cancel"
  let mapping _ = [
    "action", Mk.text (Js.runFromServer |- JsBase.to_event) ;
  ]
end)

module DetailPage_Canceled = Loader.Html(struct
  type t = <
    canceled : float ;
    canceler : string option ;
  > ;;
  let source  _ = "detail-page/canceled"
  let mapping _ = [
    "canceled",  Mk.itext (#canceled |- VDate.render) ;
    "canceler",  Mk.esc   (#canceler |- BatOption.default "") ;
  ]
end)

module DetailPage_Payer = Loader.Html(struct
  type t = I18n.text * string ;;
  let source  _ = "detail-page/payer"
  let mapping _ = [
    "label", Mk.trad fst ;
    "name",  Mk.esc  snd ;
  ]
end)

module DetailPage = Loader.Html(struct
  type t = <
    direction : [`In|`Out] ;
    amount    : int ;
    what      : I18n.text ;
    date      : string ;
    mode      : MAccountLine.Method.t ;
    canceled  : float option ;
    cancelurl : string option ;
    canceler  : string option ;
    payer     : string option ;
    creator   : string option ;
    created   : float ;
    form      : I18n.t -> View.Context.box View.t ;
  > ;;
  let source  _ = "detail-page"
  let mapping l = [
    "reason",   Mk.trad  (#what) ;
    "mode",     Mk.trad  (#mode |- VLabel.of_payment_method) ;
    "date",     Mk.iesc  (fun x i -> BatOption.default "" (MFmt.format_date (I18n.language i) (x # date))) ;
    "form",     Mk.ihtml (#form) ;
    "created",  Mk.itext (#created |- VDate.render) ;
    "creator",  Mk.esc   (#creator |- BatOption.default "") ;
    
    "canceled", Mk.sub_or 
      (fun x -> BatOption.map (fun canceled -> (object
	method canceled = canceled
	method canceler = x # canceler
      end)) (x # canceled))
      (DetailPage_Canceled.template l) (Mk.empty) ;
    
    "amount",   Mk.esc  (fun x -> VMoney.print (match x # direction with 
      | `In -> x # amount 
      | `Out -> - (x # amount) 
    )) ;

    "cancel",   Mk.sub_or (#cancelurl)
      (DetailPage_Cancel.template l) (Mk.empty) ;

    "payer",    Mk.sub_or
      (fun x -> BatOption.map (fun payer ->
	(match x # direction with 
	  | `In  -> `label "accounting.new.payer.in"
	  | `Out -> `label "accounting.new.payer.out"
	), payer) (x # payer))
      (DetailPage_Payer.template l) (Mk.empty) ;
    
    
  ]
end)
