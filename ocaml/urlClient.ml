(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

let website, def_website = O.declare O.client "" A.none

(* Subscribe and unsubscribe ============================================================================== *)

let subscribe  , def_subscribe   = O.declare O.client "subscribe" A.none
let unsubscribe, def_unsubscribe = O.declare O.client "unsubscribe" A.none

(* Articles =============================================================================================== *)

let articles, def_articles = O.declare O.client "h" (A.ri A.float) 
let article,  def_article  = O.declare O.client "b" (A.roi IBroadcast.arg A.string)

let article_url_key b = 
  let title = match b # content with 
    | `Post p -> p # title
    | `RSS  r -> r # title
  in
  OhmSlug.make title

let article_url key b = 
  Action.url article key (b # id, Some (article_url_key b))

(* Public calendar ======================================================================================== *)

let calendar, def_calendar = O.declare O.client "calendar" A.none
let event,    def_event    = O.declare O.client "calendar" (A.r IEntity.arg)

(* Intranet =============================================================================================== *)

let root,    def_root    = O.declare O.client "intranet" A.none

let intranet key list = 
  OhmBox.url (Action.url root key ()) list

let home    key = intranet key ["home"] 
let members key = intranet key ["members"] 
let forums  key = intranet key ["forums"] 
let events  key = intranet key ["events"]
