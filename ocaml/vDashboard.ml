(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open Ohm.Util
open BatPervasives

module Loader = MModel.Template.MakeLoader(struct let from = "dashboard" end)

module CalendarDay = Loader.Html(struct
  type t = <
    day     : string ; 
    content : I18n.html
  > ;;
  let source  _ = "calendar/days"
  let mapping _ = [
    "day",     Mk.str   (#day) ;
    "content", Mk.ihtml (#content) 
  ]
end)

module Calendar = Loader.Html(struct
  type t = CalendarDay.t list
  let source  _ = "calendar"
  let mapping l = [
    "days", Mk.list identity (CalendarDay.template l)
  ]
end)

module EntityListItem = Loader.Html(struct
  type t = <
    picture : string ;
    name    : I18n.text ;
    url     : string ;
    status  : VJoin.Status.t ;
  > ;;
  let source  _ = "entity-list/items"
  let mapping l = [
    "picture", Mk.esc   (#picture) ;
    "name",    Mk.trad  (#name) ;
    "url",     Mk.esc   (#url) ;
    "status",  Mk.itext (#status |- VJoin.Status.render)
  ]
end)

module EntityListRest = Loader.Html(struct
  type t = int
  let source  _ = "entity-list/rest"
  let mapping _ = [
    "text", Mk.itext begin fun x i c -> 
      let count = View.esc (string_of_int x) in
      if x = 0 then 
	I18n.get i (`label "dashboard.list.none") c
      else 
	I18n.get_param i "dashboard.list.rest" [count] c
    end ;
  ]
end)

module EntityList = Loader.Html(struct
  type t = <
    list : EntityListItem.t list ;
    rest : int option 
  >  
  let source  _ = "entity-list"
  let mapping l = [
    "items", Mk.list   (# list) (EntityListItem.template l) ;
    "rest",  Mk.sub_or (# rest) (EntityListRest.template l) Mk.empty 
  ]
end)

module DirectoryItem = Loader.Html(struct
  type t = <
    name : string ;
    url  : string ;
    pic  : string
  > ;;
  let source  _ = "directory/avatars"
  let mapping _ = [
    "url",  Mk.esc (#url) ;
    "name", Mk.esc (#name) ;
    "pic",  Mk.esc (#pic) ;
  ]
end)

module DirectoryMore = Loader.Html(struct
  type t = (string * int)
  let source  _ = "directory/more"
  let mapping _ = [
    "url",  Mk.esc (fun (x,_) -> x) ;
    "more", Mk.esc (fun (_,x) -> string_of_int x) ;
  ]
end)

module Directory = Loader.Html(struct
  type t = <
    avatars : DirectoryItem.t list ;
    url     : string ;
    members : int ;
  > ;;
  let source  _ = "directory"
  let mapping l = [
    "avatars", Mk.list   (#avatars) (DirectoryItem.template l) ;
    "more",    Mk.sub_or (fun x -> let l = List.length x # avatars in 
				   if x # members > l 
				   then Some (x # url, x # members - l)
				   else None)
      (DirectoryMore.template l) (Mk.empty)
  ]
end)

module ContactsInfo = Loader.Html(struct
  type t = < 
    label : I18n.text ;
    number : int ;
    more : bool 
  > ;;
  let source  _ = "contacts/stats"
  let mapping _ = [
    "label",  Mk.trad (#label) ;
    "number", Mk.esc (fun x ->  
	if x # more then string_of_int (x # number) ^ "+"
	else string_of_int (x # number) 
    ) 
  ]
end)

module ContactsEmpty = Loader.Html(struct
  type t = unit
  let source  _ = "contacts/empty"
  let mapping _ = []
end)

module Contacts = Loader.Html(struct
  type t = < 
    stats : ContactsInfo.t option
  > ;;
  let source  _ = "contacts"
  let mapping l = [
    "stats", Mk.sub_or (#stats) (ContactsInfo.template l) (Mk.empty) ;
    "empty", Mk.sub_or (fun x -> if x # stats = None then Some () else None)
      (ContactsEmpty.template l) (Mk.empty)
  ]
end)

module ElementContent = Loader.JsHtml(struct
  type t = Id.t * string
  let source  _ = "block/content"
  let mapping _ = [
    "id", Mk.esc (fst |- Id.str)
  ]
  let script  _ = [
    "id" , (fst |- Id.to_json) ;
    "url", (snd |- Json_type.Build.string) 
  ]
end)

module ElementAbstract = Loader.Html(struct
  type t = I18n.text
  let source  _ = "block/abstract"
  let mapping _ = [
    "text", Mk.trad identity 
  ]
end)

module Green = Loader.Html(struct
  type t = <
    action : [ `url of string | `js of JsCode.t ] ;
    label  : I18n.text
  > ;;
  let source  _ = "block/green"
  let mapping _ = [
    "action", Mk.text (fun x c -> match x # action with 
      | `url u -> View.esc u c
      | `js  j -> View.str "javascript:" c |> JsBase.to_event j) ;
    "label",  Mk.trad (#label) 
  ]
end)

module Element = Loader.Html(struct
  type t = <
    title  : I18n.text ;
    icon   : string ;
    desc   : I18n.text option ;
    url    : string ;
    action : I18n.text ;
    green  : Green.t option ;
    load   : string option ;
    access : VAccessFlag.access option ;
  > ;;
  let source  _ = "block"
  let mapping l = [
    "access",   Mk.ihtml  (#access |- VAccessFlag.render) ;
    "title",    Mk.trad   (#title) ;
    "icon",     Mk.esc    (#icon) ;
    "abstract", Mk.sub_or (#desc) (ElementAbstract.template l) (Mk.empty);
    "url",      Mk.esc    (#url) ;
    "green",    Mk.sub_or (#green) (Green.template l) (Mk.empty) ; 
    "action",   Mk.trad   (#action) ;
    "content",  Mk.sub_or (#load |- BatOption.map (fun url -> Id.gen (), url))
      (ElementContent.template l) (Mk.empty)
  ]
end)
    
let rec unzip odd = function
  | [] -> []
  | h :: t -> if odd then unzip false t else h :: unzip true t

module IndexTop = Loader.Html(struct
  type t = Element.t 
  let source  _ = "index/top"
  let mapping l = [
    "element", Mk.sub identity (Element.template l)
  ]
end)
  
module Index = Loader.Html(struct
  type t = <
    title    : I18n.text ;
    access   : VAccessFlag.access option ;
    top      : Element.t option ;
    elements : Element.t list 
  > ;; 
  let source  _ = "index"
  let mapping l = [
    "title",          Mk.trad   (#title) ;
    "access",         Mk.ihtml  (#access |- VAccessFlag.render) ;
    "top",            Mk.sub_or (#top) (IndexTop.template l) (Mk.empty) ;
    "elements-left",  Mk.list   (#elements |- unzip false) (Element.template l) ;
    "elements-right", Mk.list   (#elements |- unzip true ) (Element.template l) ;
  ] 
end)
