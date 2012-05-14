(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open Ohm.Util
open BatPervasives

module Loader = MModel.Template.MakeLoader(struct let from = "vote" end)

module VoteOpenAnswer = Loader.Html(struct
  type t = <
    checked : string ;
    value   : int ;
    label   : I18n.text ;
    kind    : string ;
    name    : string ;
    opens   : string
  > ;;
  let source  _ = "vote/open/answer"
  let mapping l = [
    "name",    Mk.esc  (#name) ;
    "value",   Mk.int  (#value) ;
    "checked", Mk.str  (#checked) ;
    "opens",   Mk.str  (#opens) ;
    "type",    Mk.esc  (#kind) ;
    "label",   Mk.trad (#label)
  ]
end)

module VoteOpenManage = Loader.Html(struct
  type t = <
    edit  : JsCode.t ;
    close : JsCode.t 
  > ;;
  let source  _ = "vote/open/manage"
  let mapping _ = [
    "edit",  Mk.text (#edit  |- JsBase.to_event) ;
    "close", Mk.text (#close |- JsBase.to_event) 
  ] 
end)

module VoteClosedEdit = Loader.Html(struct
  type t = JsCode.t
  let source  _ = "vote/closed/contents/edit"
  let mapping _ = [ "edit",  Mk.text JsBase.to_event ] 
end)

module VoteButton = Loader.Html(struct
  type t = [`Vote] IVote.id
  let source  _ = "vote/open/vote"
  let mapping _ = []
end)

module VoteOpenOpens = Loader.Html(struct
  type t = float
  let source  _ = "vote/open/opens"
  let mapping _ = [ "date", Mk.ihtml VDate.mdyhm_render ] 
end)

module VoteOpenCloses = Loader.Html(struct
  type t = float
  let source  _ = "vote/open/closes"
  let mapping _ = [ "date", Mk.ihtml VDate.mdyhm_render ] 
end)

module VoteOpenAnonymous = Loader.Html(struct
  type t = unit
  let source  _ = "vote/open/anonymous"
  let mapping _ = []
end)

module VoteOpen = Loader.Html(struct
  type t = <
    answers   : (bool * int * I18n.text) list ;
    answered  : bool ; 
    multi     : bool ;
    created   : float ;
    creator   : string ;
    profile   : string ;
    anonymous : bool ; 
    id        : [`Vote] IVote.id option ;
    opens_on  : VoteOpenOpens.t option ;
    closes_on : VoteOpenCloses.t option ;
    manage    : VoteOpenManage.t option 
  > ;;
  let source  _ = "vote/open"
  let mapping l = [
    "anonymous", Mk.sub_or  (fun x -> if x # anonymous then Some () else None) 
      (VoteOpenAnonymous.template l) Mk.empty ;
    "vote",      Mk.sub_or  (#id) (VoteButton.template l) Mk.empty ;
    "id",        Mk.esc     (#id |- BatOption.map IVote.to_string |- BatOption.default "") ;
    "date",      Mk.itext   (#created |- VDate.render) ;
    "by",        Mk.esc     (#creator) ;
    "by-url",    Mk.esc     (#profile) ;
    "opens",     Mk.sub_or  (#opens_on) (VoteOpenOpens.template l) Mk.empty ;
    "closes",    Mk.sub_or  (#closes_on) (VoteOpenCloses.template l) Mk.empty ;
    "manage",    Mk.sub_or  (#manage) (VoteOpenManage.template l) Mk.empty ;
    "answered",  Mk.str     (fun x -> if x # answered then " -answered" else "") ;
    "answer",    Mk.list    (fun x -> List.map (fun (checked,value,label) -> (object
      method checked = if checked then " checked=\"checked\"" else "" 
      method value   = value
      method label   = label 
      method kind    = if x # multi then "checkbox" else "radio"
      method name    = if x # multi then "ans" ^ string_of_int value else "ans"
      method opens   = if x # id = None then " disabled=\"disabled\"" else ""
    end)) (x # answers)) (VoteOpenAnswer.template l) 
  ]
end)

module VoteStatsAnswer = Loader.Html(struct
  type t = <
    label   : I18n.text ;
    count   : int ;
    percent : float ;
  > ;;
  let source  _ = "vote/closed/contents/answer"
  let mapping _ = [
    "label",   Mk.trad (#label) ;
    "count",   Mk.int  (#count) ;
    "percent", Mk.esc  (fun x -> Printf.sprintf "%.2f" (100. *. x # percent))
  ]
end)

module VoteStats = Loader.Html(struct
  type t = <
    answers : VoteStatsAnswer.t list ;      
    voters  : int ;
    created : float ;
    creator : string ;
    profile : string ;
    closed  : float ;
    edit    : VoteClosedEdit.t option ;
  > ;;
  let source  _ = "vote/closed/contents"
  let mapping l = [
    "date",     Mk.itext   (#created |- VDate.render) ;
    "by",       Mk.esc     (#creator) ;
    "by-url",   Mk.esc     (#profile) ;
    "voters",   Mk.int     (#voters) ;
    "edit",     Mk.sub_or  (#edit) (VoteClosedEdit.template l) Mk.empty ;
    "closed",   Mk.itext   (#closed  |- VDate.mdyhm_render) ;
    "answer",   Mk.list    (#answers |- List.sort (fun a b -> compare (b # count) (a # count)))
      (VoteStatsAnswer.template l)
  ]
end)

module VoteClosed = Loader.JsHtml(struct
  type t = < 
    id   : Id.t ;
    url  : string ;
    vote : [`Read] IVote.id
  >
  let source  _ = "vote/closed"
  let mapping _ = [
    "id",       Mk.esc (#id |- Id.str) ;
    "contents", Mk.put "" 
  ]
  let script  _ = Json_type.Build.([
    "id",   (#id |- Id.to_json) ;
    "url",  (#url |- string) ;
    "vote", (#vote |- IVote.decay |- IVote.to_json)
  ])
end)

module Vote = Loader.Html(struct
  let as_open   = function `Open   o -> Some o | _ -> None
  let as_closed = function `Closed c -> Some c | _ -> None
  type t = <
    question : string ;
    what : [`Open of VoteOpen.t | `Closed of VoteClosed.t]
  > ;;
  let source  _ = "vote"
  let mapping l = [
    "question", Mk.str (#question |- VText.format) ;
    "open",     Mk.sub_or (#what |- as_open) (VoteOpen.template l) Mk.empty ;
    "closed",   Mk.sub_or (#what |- as_closed) (VoteClosed.template l) Mk.empty ;
  ]
end)

let page_empty = VCore.empty VIcon.Large.text_list_bullets (`label "votes.empty")

module Page = Loader.JsHtml(struct
  type t = <
    actions : I18n.html ;
    list    : Vote.t list ;
    url     : string
  > ;;
  let source  _ = "page"
  let mapping l = [
    "actions", Mk.ihtml   (#actions) ;
    "list",    Mk.list_or (#list) (Vote.template l) page_empty ;
  ]
  let script  _ = Json_type.Build.([
    "url", (#url |- string)
  ])
end)
