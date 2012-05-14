(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open BatPervasives

module Loader = MModel.Template.MakeLoader(struct let from = "broadcast" end)

let empty = VCore.empty VIcon.Large.transmit (`label "broadcast.list.empty") 

module ProfileListItemRSS = Loader.Html(struct
  type t = string
  let source  _ = "list/list/rss"
  let mapping _ = [
    "url", Mk.str VText.secure_link
  ]
end)

module ProfileListItemForward = Loader.Html(struct
  type t = IBroadcast.t
  let source  _ = "list/list/forward"
  let mapping _ = [
    "id", Mk.esc IBroadcast.to_string
  ]
end)

module ProfileListItemDelete = Loader.Html(struct
  type t = IBroadcast.t
  let source  _ = "list/list/delete"
  let mapping _ = [
    "id", Mk.esc IBroadcast.to_string
  ]
end)

module ProfileListPost = Loader.JsHtml(struct
  type t = string
  let source  _ = "list/post"
  let mapping _ = []
  let script  _ = Json_type.Build.([
    "post_url", string
  ])
end)

module ProfileListItem = Loader.Html(struct
  type t = <
    pic     : string ;
    name    : string ;
    title   : string ;
    text    : string ;
    key     : string ;
    time    : float  ;
    forward : bool   ;
    id      : IBroadcast.t ;
    can_fwd : bool ;
    can_del : bool ;
    url     : string ;
    rss     : string option ;
  >
  let source  _ = "list/list"
  let mapping l = [
    "forwarded", Mk.str    (fun x -> if x # forward then " -forward" else "") ;
    "name",      Mk.esc    (#name) ;
    "key",       Mk.esc    (#key) ;
    "url",       Mk.esc    (#url) ;
    "time",      Mk.ihtml  (#time |- VDate.render) ;
    "title",     Mk.esc    (#title) ;
    "text",      Mk.str    (#text) ;
    "pic",       Mk.esc    (#pic) ;
    "rss",       Mk.sub_or (#rss) (ProfileListItemRSS.template l) Mk.empty ;
    "delete",    Mk.sub_or (fun x -> if x # can_del then Some x # id else None) (ProfileListItemDelete.template  l) Mk.empty ;
    "forward",   Mk.sub_or (fun x -> if x # can_fwd then Some x # id else None) (ProfileListItemForward.template l) Mk.empty ;
  ]
end)

module ProfileList = Loader.JsHtml(struct
  type t = <      
    list : ProfileListItem.t list ;
    post : ProfileListPost.t option ;
    delete : string option 
  >
  let source  _ = "list"
  let mapping l = [
    "list", Mk.list_or (#list) (ProfileListItem.template l) empty ;
    "post", Mk.sub_or (#post) (ProfileListPost.template l) Mk.empty 
  ]
  let script _ = Json_type.Build.([
    "delete_url", (#delete |- optional string) 
  ])
end)
