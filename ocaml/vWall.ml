(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open Ohm.Template
open BatPervasives

let load name = MModel.Template.load "wall" name
module Loader = MModel.Template.MakeLoader(struct let from = "wall" end)

module Home = Loader.Html(struct
  type t = string * string
  let source  _ = "home"
  let mapping _ = [
    "wall" , Mk.html O.Box.draw_container 
  ]
end)

(* Reply form ------------------------------------------------------------------------------ *)

module ReplyForm = Loader.Html(struct
  type t = <
    url  : string ;
    init : FWall.Reply.Form.t
  > ;;
  let source  _ = "reply-form"
  let mapping _ = 
    [
      "cancel",     Mk.text (fun _ -> JsBase.to_event Js.Dialog.close)
    ] |> FWall.Reply.Form.to_mapping 
	~prefix:"wall-reply"
	~url:  (#url) 
	~init: (#init)
end)

module ReplyForbidden = Loader.Html(struct
  type t = unit
  let source = function `Fr -> "reply-forbidden-fr"
  let mapping _ = [
    "cancel",     Mk.text (fun _ -> JsBase.to_event Js.Dialog.close)
  ]
end)

(* Single reply ---------------------------------------------------------------------------- *)

class reply
  ~pic 
  ~name
  ~role
  ~url
  ~text
  ~date = object
      
  val pic = pic
  method pic = (pic : string)

  val url = url
  method url = (url : string)

  val name = name
  method name = (name : string)

  val role = role
  method role = match role with 
    | Some role -> "(" ^ role ^ ")"
    | None -> ""

  val text = text
  method text = VText.format ~icons:VIcon.smileys text

  val abuse = Id.gen ()
  method abuse = Id.str abuse

  val date = date
  method date = (date : float)

end

module Reply = Loader.Html(struct
  type t = reply
  let source  _ = "reply"
  let mapping _ = [
    "pic",   Mk.esc   (#pic) ;
    "url",   Mk.esc   (#url) ;
    "name",  Mk.esc   (#name) ;
    "role",  Mk.esc   (#role) ;
    "date",  Mk.ihtml (#date |- VDate.render) ;
    "text",  Mk.str   (#text) ;
    "abuse", Mk.esc   (#abuse) ;
  ]
end)

(* Main wall rendering ----------------------------------------------------------- *)

class item 
  ~id
  ~pic 
  ~url
  ~name
  ~role
  ~text
  ~reply
  ~like
  ~likes 
  ~liked
  ~react
  ~replies
  ~remove
  ~more
  ~attach
  ~kind
  ~date = object
      
  val id = id 
  method id = Id.str id

  val url = (url : string)
  method url = url

  val pic = pic
  method pic = (pic : string)

  val name = name
  method name = (name : string)

  val role = role
  method role = match role with 
    | Some role -> "(" ^ role ^ ")"
    | None -> ""

  val text = text
  method text = VText.format ~icons:VIcon.smileys text

  val react = react
  val like  = (like : string)
  val liked = (liked : bool)
  val likes = (likes : int)

  method like = if react then Some (object
    method like = like
    method liked = liked
    method likes = likes
  end) else None

  val reply = reply
  method reply = if react then Some (reply : string) else None

  val remove = (remove : string option)
  method remove = remove

  val replies = (replies:reply list)
  method replies = replies

  val abuse = Id.gen ()
  method abuse = Id.str abuse

  val date = date
  method date = (date : float)

  val attach = attach
  method attach = (attach : View.html)

  val more = (more : string option)
  method more = more

  val kind = kind
  method icon = match kind with 
    | `none  -> VIcon.user_comment
    | `image -> VIcon.picture
    | `poll  -> VIcon.chart_bar
    | `doc e -> VIcon.of_extension e

end

module MoreReplies = Loader.Html(struct
  type t = string 
  let source  _ = "more-replies"
  let mapping _ = [
    "more", Mk.text (Js.moreReplies |- JsBase.to_event)
  ]
end)

module ItemReply = Loader.Html(struct
  type t = string
  let source  _ = "item/reply"
  let mapping _ = [
    "reply",   Mk.text (Js.runFromServer |- JsBase.to_event)
  ]
end)

module ItemRemove = Loader.Html(struct
  type t = string
  let source  _ = "item/remove"
  let mapping _ = [
    "remove",   Mk.text (Js.runFromServer |- JsBase.to_event)
  ]
end)

module ItemLike = Loader.Html(struct
  type t = <
    likes : int ;
    liked : bool ;
    like  : string
  >
  let source  _ = "item/like"
  let mapping _ = [
    "likes",   Mk.int  (#likes) ;
    "liked",   Mk.str  (fun x -> if x # liked then " -liked" else "")  ;
    "like",    Mk.text (#like |- Js.like |- JsBase.to_event) ;
  ]
end)

module Item = Loader.Html(struct
  type t = item
  let source  _ = "item"
  let mapping l = [
    "id",      Mk.esc    (#id) ;
    "url",     Mk.esc    (#url) ;
    "pic",     Mk.esc    (#pic) ;
    "name",    Mk.esc    (#name) ;
    "role",    Mk.esc    (#role) ;
    "icon",    Mk.esc    (#icon) ;
    "date",    Mk.ihtml  (#date |- VDate.render) ;
    "text",    Mk.str    (#text) ;
    "reply",   Mk.sub_or (#reply)   (ItemReply.template l) (Mk.empty) ;
    "replies", Mk.list   (#replies) (Reply.template l) ;
    "like",    Mk.sub_or (#like)    (ItemLike.template l) (Mk.empty) ;
    "remove",  Mk.sub_or (#remove)  (ItemRemove.template l) (Mk.empty) ;
    "abuse",   Mk.esc    (#abuse) ;
    "more",    Mk.sub_or (#more)    (MoreReplies.template l) (Mk.empty) ;
    "attach",  Mk.html   (#attach)
  ]
end)

(* Chat item -------------------------------------------------------------- *)

class chat_item ~id ~date ~participants ~lines ~url ~avatars ~label = object

  val id : Id.t = id
  method id = Id.str id

  val date : float = date
  method date = date

  val participants : int = participants
  method participants = participants

  val lines : int = lines
  method lines = lines

  val url : string = url
  method url = url

  val avatars : (string * string) list = avatars
  method avatars = avatars

  val label : I18n.text = label
  method label = label

end

module ChatItemAvatar = Loader.Html(struct
  type t = string * string
  let source  _ = "item-chat/avatars"
  let mapping _ = [
    "name", Mk.esc fst ;
    "pic",  Mk.esc snd
  ]
end)

module ChatItem = Loader.Html(struct
  type t = chat_item
  let source  _ = "item-chat"
  let mapping l = [
    "participants", Mk.int    (#participants) ;
    "lines",        Mk.int    (#lines) ;
    "date",         Mk.ihtml  (#date |- VDate.render) ;
    "url",          Mk.esc    (#url) ;
    "id",           Mk.esc    (#id) ;
    "avatars",      Mk.list   (#avatars) (ChatItemAvatar.template l) ;
    "label",        Mk.trad   (#label) 
  ]
end)

(* Chat request item -------------------------------------------------------------- *)

class chat_request_item ~id ~date ~topic ~chat ~name ~picture ~url = object

  val id : Id.t = id
  method id = Id.str id

  val date : float = date
  method date = date

  val name : string = name
  method name = name

  val url : string = url
  method url = url

  val picture : string = picture
  method picture = picture

  val topic : string = topic
  method topic = topic

  val chat : string = chat
  method chat = chat

end

module ChatRequestItem = Loader.Html(struct
  type t = chat_request_item
  let source  _ = "item-chat_request"
  let mapping l = [
    "date",         Mk.ihtml (#date |- VDate.render) ;
    "url",          Mk.esc   (#url) ;
    "id",           Mk.esc   (#id) ;
    "pic",          Mk.esc   (#picture) ;
    "topic",        Mk.esc   (#topic) ;
    "name",         Mk.esc   (#name) ;
    "chat",         Mk.esc   (#chat) 
  ]
end)


(* Link ------------------------------------------------------------------- *)

module MoreLink = Loader.Html (struct
  type t = JsCode.t
  let source  _ = "more-link"
  let mapping _ = [
    "onclick", Mk.text (JsBase.to_event)
  ] 
end)

(* Unavailable wall ------------------------------------------------------- *)

module N = Loader.Html(struct
  type t = unit
  let source    = function `Fr -> "n-fr"
  let mapping _ = []
end)

(* Read-only wall --------------------------------------------------------- *)

let r_empty = VCore.empty VIcon.Large.newspaper (`label "wall.empty") 

module R = Loader.Html(struct
  type t = <
    list : Ohm.View.html list ;
    more : JsCode.t option
  > ;;
  let source  _ = "r"
  let mapping l = [
    "list",     Mk.list_or (#list) (Mk.verbatim)      r_empty ;
    "more",     Mk.sub_or  (#more) (MoreLink.template l) Mk.empty ;
  ]   
end)

(* Read-write wall -------------------------------------------------------- *)

let rw_empty = VCore.empty VIcon.Large.newspaper (`label "wall.empty") 

module RW = Loader.Html(struct
  type t = <
    list      : Ohm.View.html list ;
    id        : Id.t ;
    more      : MoreLink.t option ;
    post_url  : string ;
    post_init : FWall.Post.Form.t ;
    actions   : I18n.html
  > ;;
  let source  _ = "rw"
  let mapping l = [
    "list",     Mk.list_or (#list) (Mk.verbatim) rw_empty ;
    "id",       Mk.esc     (#id |- Id.str) ;
    "more",     Mk.sub_or  (#more) (MoreLink.template l) Mk.empty ;
    "actions",  Mk.ihtml   (#actions)
  ] |> FWall.Post.Form.to_mapping 
      ~prefix:"post-form"
      ~url:  (#post_url) 
      ~init: (#post_init)
end)

(* Poll elements ----------------------------------------------------------- *)

module Poll = struct

  module New = Loader.Html(struct
    type t = <
      url  : string ;
      init : FPoll.Create.Form.t
  > ;;
  let source  _ = "poll-new"
  let mapping _ = FPoll.Create.Form.to_mapping
    ~prefix:"poll-create"
    ~url:  (#url)
    ~init: (#init)
    []
  end)

end

(* Display more wall elements ------------------------------------------------ *)

module More = Loader.Html(struct
  type t = <
    list : Ohm.View.html list ;
    more : JsCode.t option 
  > ;;
  let source  _ = "more"
  let mapping l = [
    "list",     Mk.html    (#list |- View.concat) ;
    "more",     Mk.sub_or  (#more) (MoreLink.template l) Mk.empty ;
  ] 
end)

(* Displaying single items --------------------------------------------------- *)

module ShowItem = Loader.Html(struct
  type t = <
    contents : View.html ;
    back     : string
  > ;; 
  let source  _ = "show-item"
  let mapping _ = [
    "contents", Mk.html (#contents) ;
    "back",     Mk.esc  (#back)
  ]
end)

module Missing = Loader.Html(struct
  type t = unit
  let source  _ = "missing"
  let mapping _ = []
end)
