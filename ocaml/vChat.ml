(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open BatPervasives

module Loader = MModel.Template.MakeLoader(struct let from = "chat" end) 

module AvatarFmt = Fmt.Make(struct
  type json t = <
    id   : IAvatar.t ;
    name : string ;
    pic  : string 
  >
end)
  
module Post = Loader.JsHtml(struct
  type t = <
    active : View.html ;
    post   : string ;
    user   : string ;
    chat   : string ; 
    ensure : string ;
    self   : AvatarFmt.t ;
    last   : MChat.Line.t list 
  > ;;
  let source  _ = "post"
  let mapping _ = [ "active", Mk.html (#active) ]
  let script  _ = Json_type.Build.([
    "post_url",   (#post   |- string) ;
    "last",       (#last   |- list MChat.Line.to_json) ;
    "self",       (#self   |- AvatarFmt.to_json)  ;
    "user_url",   (#user   |- string) ;
    "chat_url",   (#chat   |- string) ;
    "ensure_url", (#ensure |- string)
  ])
end)

let colors = 
  [| "#555" ; "#55B" ; "#5BB" ; "#5B5" ; "#BB5" ; "#B55" ; "#B5B" |]

let color i = colors.( i mod Array.length colors ) 

module ViewText = Loader.Html(struct
  type t = <
    date  : float ;
    name  : string ;
    text  : string ;
    url   : string ;
    color : int
  > ;;
  let source  _ = "view/text"
  let mapping _ = [
    "date",  Mk.itext (#date |- VDate.mdyhm_render) ;
    "name",  Mk.esc   (#name) ;
    "text",  Mk.esc   (#text) ;
    "url",   Mk.esc   (#url) ;
    "color", Mk.str   (#color |- color) 
  ]
end)

module View = Loader.Html(struct
  type t = <
    file  : string ;
    back  : string ;
    text : ViewText.t list ;
  > ;;
  let source  _ = "view"
  let mapping l = [
    "file",  Mk.esc   (#file) ;
    "back",  Mk.esc   (#back) ;
    "text", Mk.list (#text) (ViewText.template l)
  ]
end)

module DownloadText = Loader.Text(struct
  type t = <
    hour   : int ;
    minute : int ;
    name   : string ;
    text   : string 
  > ;;
  let source  _ = "download/text"
  let mapping _ = [
    "hour",   Mk.esc (#hour |- Printf.sprintf "%02d") ;
    "name",   Mk.esc (#name) ;
    "text",   Mk.esc (#text) ;
    "minute", Mk.esc (#minute |- Printf.sprintf "%02d") ;
  ]
end)

module Download = Loader.Text(struct
  type t = <
    text : DownloadText.t list ;
  > ;;
  let source  _ = "download"
  let mapping l = [
    "text", Mk.list (#text) (DownloadText.template l)
  ]
end)

module ActiveRoom = Loader.Html(struct
  type t = (I18n.text * string * string) 
  let source  _ = "active/room"
  let mapping _ = [
    "url",  Mk.esc (fun  (_,_,url)  -> url) ;
    "name", Mk.trad (fun (name,_,_) -> name) ;
    "pic",  Mk.esc  (fun (_,pic,_)  -> pic) 
  ] 
end)

module Active = Loader.Html(struct
  type t = ActiveRoom.t list
  let source  _ = "active"
  let mapping l = [ "room", Mk.list identity (ActiveRoom.template l) ]
end)
