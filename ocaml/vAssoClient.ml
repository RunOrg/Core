(* © 2012 Runorg *)

open Ohm
open Ohm.Util
open Ohm.Template
open BatPervasives

module Loader = MModel.Template.MakeLoader(struct let from = "assoClient" end)

module Home = Loader.Html(struct
  type t = string * string
  let source  _ = "head"
  let mapping _ = [
    "content", Mk.html O.Box.draw_container
  ]
end)

module Buy = Loader.Html(struct
  type t = <
    cancel_url : string ;
    form_url   : string ;
    init       : FClient.Buy.Form.t
  > ;;
  let source  _ = "buy"
  let mapping _ = [
    "cancel", Mk.esc (#cancel_url) 
  ] |> FClient.Buy.Form.to_mapping
      ~prefix:"buy"
      ~init:(#init)
      ~url:(#form_url) 
end)

let price p = 
  Printf.sprintf "%.02f" (float_of_int p /. 100.)

module OrderLine = Loader.Html(struct
  type t = <
    item   : I18n.text ;
    detail : I18n.text ;
    price  : int
  > ;;
  let source  _ = "order-line"
  let mapping _ = [
    "item",     Mk.trad (#item) ;
    "detail",   Mk.trad (#detail) ;
    "negative", Mk.str  (fun x -> if x # price < 0 then " -negative" else "") ;
    "price",    Mk.str  (#price |- price)
  ]
end)

module OrderEdit = Loader.Html(struct
  type t = <
    edit   : string ;
    pay    : string ;
    cancel : string 
  > ;;
  let source  _ = "order-edit"
  let mapping _ = [
    "cancel", Mk.esc  (#cancel) ;
    "pay",    Mk.text (#pay |- Js.runFromServer ~disable:true |- JsBase.to_event) ;
    "edit",   Mk.esc  (#edit) ;
  ]
end)

module OrderPay = Loader.Html(struct
  type t = <
    pay    : string ;
    cancel : string 
  > ;;
  let source  _ = "order-pay"
  let mapping _ = [
    "cancel", Mk.esc  (#cancel) ;
    "pay",    Mk.text (#pay |- Js.runFromServer ~disable:true |- JsBase.to_event) ;
  ]
end)

module OrderBack = Loader.Html(struct
  type t = string
  let source  _ = "order-back"
  let mapping _ = [
    "cancel", Mk.esc identity 
  ]
end)

module Order = Loader.Html(struct
  type t = <
    lines   : OrderLine.t list ;
    ht      : int ;
    tva     : int ;
    ttc     : int ;
    buttons : I18n.html ;
    id      : IRunOrg.Order.t ;
    time    : float ;
    name    : string ;
    address : string ;
  > ;;
  let source = function `Fr -> "order-fr"
  let mapping l = [
    "lines",     Mk.list  (#lines) (OrderLine.template l) ;
    "ht",        Mk.str   (#ht  |- price) ;
    "tva",       Mk.str   (#tva |- price) ;
    "ttc",       Mk.str   (#ttc |- price) ;
    "buttons",   Mk.ihtml (#buttons) ;
    "reference", Mk.esc   (#id |- IRunOrg.Order.to_string |- Util.base62_to_base34) ;
    "date",      Mk.itext (#time |- VDate.mdy_render) ;
    "name",      Mk.esc   (#name) ;
    "address",   Mk.esc   (#address) ;
  ]
end)

let offer_name offer mem_offer i = 
  I18n.get i offer |- (
    match mem_offer with 
      | None -> identity
      | Some mem_offer -> View.str " + " |- I18n.get i mem_offer
  )
  
module OrderItem = Loader.Html(struct
  type t = <
    offer     : I18n.text ;
    mem_offer : I18n.text option ;    
    id        : IRunOrg.Order.t ;
    time      : float ;
    price     : int ;
    url       : string 
  >
  let source  _ = "order-item"
  let mapping _ = [
    "url",   Mk.esc   (#url) ;
    "order", Mk.esc   (#id |- IRunOrg.Order.to_string |- Util.base62_to_base34) ;
    "name",  Mk.ihtml (fun x -> offer_name (x # offer) (x # mem_offer)) ;
    "date",  Mk.itext (#time |- VDate.render) ;
    "price", Mk.esc   (#price |- price) ;
  ]
end)

module OrderList = Loader.Html(struct
  type t = OrderItem.t list
  let source  _ = "order-list"
  let mapping l = [
    "list", Mk.list identity (OrderItem.template l)
  ]
end)

module ClientPaying = Loader.Html(struct
  type t = <
    offer : I18n.text ;
    mem_offer : I18n.text option ;
    used_seats : int ;
    seats : int ;
    used_memory : int ;
    memory : int ;
    date : string ;
  > ;;    
  let source  _ = "client/paying"
  let mapping _ = [
    "used-seats",  Mk.int (#used_seats) ;
    "seats",       Mk.int (#seats) ;
    "used-memory", Mk.int (#used_memory) ;
    "memory",      Mk.int (#memory) ;
    "last-day",    Mk.esc (#date) ;
    "offer",       Mk.ihtml (fun x -> offer_name (x # offer) (x # mem_offer)) ;
  ]
end)

module ClientFree = Loader.Html(struct
  type t = <
    used_seats : int ;
    used_memory : int ;
    memory : int ;
  > ;;    
  let source  _ = "client/free"
  let mapping _ = [
    "seats",       Mk.int (#used_seats) ;
    "used-memory", Mk.int (#used_memory) ;
    "memory",      Mk.int (#memory) ;
  ]
end)

module Client = Loader.Html(struct
  type t = <
    current : [ `paying of ClientPaying.t | `free of ClientFree.t ] ;
    actions : I18n.html ;
    orders : OrderItem.t list option
  > ;;
  let source  _ = "client"
  let mapping l = [
    "paying",  Mk.sub_or (fun x -> match x # current with 
      | `paying p -> Some p
      | `free   _ -> None) (ClientPaying.template l) (Mk.empty) ;
    "free",    Mk.sub_or (fun x -> match x # current with 
      | `free   f -> Some f
      | `paying _ -> None) (ClientFree.template l) (Mk.empty) ;
    "actions", Mk.ihtml  (#actions) ;
    "orders",  Mk.sub_or (#orders) (OrderList.template l) (Mk.empty);
  ]
end)
