(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module Common = UrlClient_common

include UrlClient_common

let website,  def_website  = O.declare O.client "" A.none
let notfound, def_notfound = O.declare O.client "" A.i  
let about,    def_about    = O.declare O.client "about" A.none

(* Subscribe and unsubscribe ================================================================ *)

let subscribe  , def_subscribe   = O.declare O.client "subscribe" A.none
let unsubscribe, def_unsubscribe = O.declare O.client "unsubscribe" A.none

(* Join ===================================================================================== *)

let join,   def_join   = O.declare O.client "join" (A.o IGroup.arg)
let doJoin, def_doJoin = O.declare O.client "join/public" (A.r IGroup.arg) 

(* Exports ================================================================================== *)

module Export = struct
  let status,   def_status   = O.declare O.client "export/status" (A.rr IExport.arg A.string)
  let download, def_download = O.declare O.client "export" (A.rr IExport.arg A.string)
end

(* Articles ================================================================================= *)

let articles, def_articles = O.declare O.client "h" (A.ri A.float) 
let article,  def_article  = O.declare O.client "b" (A.roi IBroadcast.arg A.string)

let article_url_key b = 
  let title = match b # content with 
    | `Post p -> p # title
    | `RSS  r -> r # title
  in
  let s = OhmSlug.make title in
  if String.length s > 100 then String.sub s 0 100 else s 

let article_url key b = 
  Action.url article key (b # id, Some (article_url_key b))

(* Public calendar ========================================================================== *)

let calendar, def_calendar = O.declare O.client "calendar" A.none
let event,    def_event    = O.declare O.client "calendar" (A.r IEvent.arg)

(* Intranet ================================================================================= *)

let ajax,    def_ajax      = O.declare O.client "intranet/ajax" (A.n A.string)

let newhere, def_newhere   = O.declare O.client "newhere" A.none

let intranet = Action.rewrite ajax "intranet/ajax" "intranet/#"

module Like       = UrlClient_like
module Comment    = UrlClient_comment
module Item       = UrlClient_item
module MiniPoll   = UrlClient_miniPoll 
module Members    = UrlClient_members
module Events     = UrlClient_events
module Website    = UrlClient_website
module Invite     = UrlClient_invite
module Join       = UrlClient_join
module Profile    = UrlClient_profile
module Search     = UrlClient_search
module Inbox      = UrlClient_inbox
module Discussion = UrlClient_discussion
  
let pickAvatars, def_pickAvatars = O.declare O.client "search/people" A.none

let atom, def_atom = O.declare O.client "search/atom" (A.o IAtom.Nature.arg)
