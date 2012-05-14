(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open Ohm.Util
open BatPervasives

module Loader = MModel.Template.MakeLoader(struct let from = "folder" end)

module ListItem = Loader.Html(struct
  type t = <
    by       : string ;
    by_url   : string ;
    download : string ;
    details  : string ;
    time     : float ;
    size     : float ;
    likes    : int ;
    comments : int ;
    title    : string ;
    ext      : MFile.Extension.t
  > ;;
  let source  _ = "list/items"
  let mapping _ = [
    "by",       Mk.esc   (#by) ;
    "by_url",   Mk.esc   (#by_url) ;
    "details",  Mk.esc   (#details) ;
    "download", Mk.esc   (#download) ;
    "date",     Mk.itext (#time |- VDate.render) ;
    "likes",    Mk.esc   (fun x -> if x # likes = 0    then "" else string_of_int (x # likes)) ;
    "comments", Mk.esc   (fun x -> if x # comments = 0 then "" else string_of_int (x # comments)) ;
    "title",    Mk.esc   (#title) ;
    "ext",      Mk.esc   (#ext |- VIcon.of_extension) ;
    "size",     Mk.itext (#size |- VFilesize.render) 
  ]
end)

module Attached = Loader.Html(struct
  type t = <
    download : string ;
    size     : float ;
    title    : string ;
  > ;;
  let source  _ = "attached"
  let mapping _ = [
    "download", Mk.esc   (#download) ;
    "title",    Mk.esc   (#title) ;
    "size",     Mk.itext (#size |- VFilesize.render) 
  ]
end)

module Item = Loader.Html(struct
  type t = <
    contents : View.html ;
    back     : string
  > ;; 
  let source  _ = "item"
  let mapping _ = [
    "contents", Mk.html (#contents) ;
    "back",     Mk.esc  (#back)
  ]
end)

module ListMore = Loader.Html(struct
  type t = View.text
  let source  _ = "list/more" 
  let mapping _ = [
    "onclick", Mk.text identity
  ]
end)

module More = Loader.Html(struct
  type t = < 
    list : ListItem.t list ;
    more : View.text option
  > ;;
  let source  _ = "list" 
  let mapping l = [
    "items", Mk.list   (#list) (ListItem.template l) ;
    "more",  Mk.sub_or (#more) (ListMore.template l) (Mk.empty)
  ] 
end)

module Upload = Loader.JsHtml(struct
  type t = <
    cancel  : string ;
    put     : string ;
    get     : string ;
    title   : string
  > ;;
  let source  _ = "page/upload"
  let mapping _ = []
  let script  _ = [
    "cancel",  (fun x -> Json_type.String (x # cancel)) ;
    "put",     (fun x -> Json_type.String (x # put)) ;
    "get",     (fun x -> Json_type.String (x # get)) ;
    "title",   (fun x -> Json_type.String (x # title)) ;
  ]
end)

module Missing = Loader.Html(struct
  type t = unit
  let source  _ = "missing"
  let mapping _ = []
end)

type page = < 
  list   : ListItem.t list ;
  more   : View.text option ;
  upload : Upload.t option
> ;;

module Empty = Loader.Html(struct
  (* Same as below because of silly type system... *)
  type t = page
  let source  _ = "empty"
  let mapping _ = []
end)

module Page = Loader.JsHtml(struct
  type t = page
  let source  _ = "page" 
  let mapping l = [
    "empty",  Mk.put     "" ;
    "items",  Mk.list_or (#list) (ListItem.template l) (Empty.template l) ;
    "more",   Mk.sub_or  (#more) (ListMore.template l) (Mk.empty) ;
    "upload", Mk.sub_or  (#upload) (Upload.template l) (Mk.empty)  
  ]
  let script  _ = []
end)

let _forbidden = VCore.empty VIcon.Large.lock (`label "folder.forbidden")
let forbidden i18n ctx = 
  to_html _forbidden () i18n ctx
