(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open BatPervasives

let load name = MModel.Template.load "mail" name

module Loader = MModel.Template.MakeLoader(struct let from = "mail" end)

module type DUAL = sig
  type t
  val source  : string
  val title   : string
  val mapping : 
    esc:bool
    -> [`Fr]
    -> (string * ((t, View.Context.text) template -> (t, View.Context.text) template)) list
end

module MakeDual = functor(Dual:DUAL) -> struct

  type t = Dual.t

  module Text = Loader.Text(struct
    type t = Dual.t
    let source    = function `Fr -> Dual.source ^ "-fr"
    let mapping l = Dual.mapping ~esc:false l
  end)

  module Html = Loader.Text(struct
    type t = Dual.t
    let source    = function `Fr -> Dual.source ^ "-html-fr"
    let mapping l = Dual.mapping ~esc:true l
  end)

  let template esc lang = 
    if esc then Html.template lang else Text.template lang

  let send send i18n ?params data = 
    send 
      ~subject:(match params with 
	| None -> I18n.get i18n (`label Dual.title)
	| Some p -> I18n.get_param i18n Dual.title p)
      ~text:(Text.render data i18n)
      ~html:(Some (Html.render data i18n))
      
  let send_from send i18n from ?params data = 
    send
      ~from:(Some from)
      ~subject:(match params with 
	| None -> I18n.get i18n (`label Dual.title)
	| Some p -> I18n.get_param i18n Dual.title p) 
      ~text:(Text.render data i18n)
      ~html:(Some (Html.render data i18n))

end

module Message = MakeDual(struct
  type t = <
    text     : string ;
    instance : string ;
    from     : string ;
    url      : string ;
    title    : string
  > ;;
  let title        = "mail.message.received.subject" 
  let source       = "message_received"
  let mapping ~esc l = 
    let e = if esc then Mk.esc else Mk.str in [ 
      "text"      , Mk.str (#text |- 
	  (if esc then VText.format ~icons:[] else VText.format_mail)) ;
      "instance"  , e (#instance) ;
      "from"      , e (#from) ;
      "url"       , e (#url) ;
      "title"     , e (#title) 
    ]
end)

module Notify = struct

  module Reconfirm = MakeDual(struct
    type t = <
      fullname : string ;
      url      : string ;
    > ;;
    let title          = "mail.mail-confirm.subject"
    let source         = "reconfirm"
    let mapping ~esc l =
      let e = if esc then Mk.esc else Mk.str in [ 
      "fullname", e (#fullname) ;
      "url"     , e (#url) ;
    ]
  end)

  module ConfirmMerge = Loader.Text(struct
    type t = <
      fullname  : string ;
      url       : string ;
      new_email : string ;
      old_email : string
    > ;;
    let source    = function `Fr -> "confirm-merge-fr"
    let mapping _ = [
      "fullname",  Mk.str (#fullname) ;
      "url",       Mk.str (#url) ;
      "new-email", Mk.str (#new_email) ;
      "old-email", Mk.str (#old_email) 
    ]
  end)

  module JoinPending = MakeDual(struct
    type t = <
      fullname  : string ;
      instance  : string ;
      from      : string ;
      entity    : I18n.text ;
      url       : string ;
    > ;;
    let title        = "mail.notify.join_pending.subject"
    let source       = "join_pending"
    let mapping ~esc l =
      let e = if esc then Mk.esc else Mk.str in [      
      "fullname"  , e       (#fullname) ;
      "instance"  , e       (#instance) ;
      "entity"    , Mk.trad (#entity) ;
      "from"      , e       (#from) ;
      "url"       , e       (#url) 
    ]
  end)

  module NetworkInvite = MakeDual(struct
    type t = <
      text     : string ;
      instance : string ;
      url      : string 
    > ;;
    let title        = "mail.notify.network_invite.subject" 
    let source       = "network-invite"
    let mapping ~esc l = 
      let e = if esc then Mk.esc else Mk.str in [
      "text"      , Mk.str (#text |- 
	  (if esc then VText.format ~icons:[] else VText.format_mail)) ;
      "instance", e (#instance) ;
      "url",      e (#url) 
    ]
  end) 

  module NetworkConnect = MakeDual(struct
    type t = <
      followed : string ;
      follower : string ;
      url      : string 
    > ;;
    let title        = "mail.notify.network_connect.subject" 
    let source       = "network-connect"
    let mapping ~esc l = 
      let e = if esc then Mk.esc else Mk.str in [
	"followed", e (#followed) ;
	"follower", e (#follower) ;
	"url",      e (#url) 
      ]
  end) 

  type invite = <
    fullname : string ;
    instance : string ;
    entity   : I18n.text ;
    from     : string ;
    url      : string ;
  >

  module MakeInvite = functor(Where:sig val name : string end) -> struct
    include MakeDual(struct
      type t           = invite
      let title        = "mail.notify.invite.subject"
      let source       = Where.name
      let mapping ~esc l = 
	let e = if esc then Mk.esc else Mk.str in [      
	"fullname"  , e       (#fullname) ;
	"instance"  , e       (#instance) ;
	"entity"    , Mk.trad (#entity) ;
	"from"      , e       (#from) ;
	"url"       , e       (#url) 
      ]
    end)
  end

  module InviteSubscription = MakeInvite(struct let name = "invite_subscription" end)
  module InviteEvent        = MakeInvite(struct let name = "invite_event"        end)
  module InviteGroup        = MakeInvite(struct let name = "invite_group"        end)
  module InviteForum        = MakeInvite(struct let name = "invite_forum"        end)
  module InviteAlbum        = MakeInvite(struct let name = "invite_album"        end)
  module InvitePoll         = MakeInvite(struct let name = "invite_poll"         end)
  module InviteCourse       = MakeInvite(struct let name = "invite_course"       end)

  module PublishItem = MakeDual(struct
    type t = <
      text     : string ;
      instance : string ;
      from     : string ;
      url      : string
    > ;;
    let title = "mail.notify.publish_item.subject" 
    let source = "publish_item"
    let mapping ~esc l = 
      let e = if esc then Mk.esc else Mk.str in [ 
	"text"      , Mk.str (#text |- 
	    (if esc then VText.format ~icons:[] else VText.format_mail)) ;
	"instance"  , e (#instance) ;
	"from"      , e (#from) ;
	"url"       , e (#url) 
      ]
  end)

  module ChatRequest = MakeDual(struct
    type t = <
      text     : string ; 
      where    : I18n.text ;
      instance : string ;
      from     : string ;
      url      : string
    > ;;
    let title = "mail.notify.chat_request.subject" 
    let source = "chat_request"
    let mapping ~esc l = 
      let e = if esc then Mk.esc else Mk.str in [ 
	"text"      , e (#text) ;
	"instance"  , e (#instance) ;
	"from"      , e (#from) ;
	"url"       , e (#url) ;
	"where"     , Mk.trad (#where) 
      ]
  end)

  module LikeItem = MakeDual(struct
    type t = <
      author   : string ;
      fullname : string ;
      instance : string ;
      from     : string ;
      url      : string 
    > ;;
    let title        = "mail.notify.like_item.subject" 
    let source       = "like_item"
    let mapping ~esc l = 
      let e = if esc then Mk.esc else Mk.str in [ 
      "author"    , e (#author) ;
      "fullname"  , e (#fullname) ;
      "instance"  , e (#instance) ;
      "from"      , e (#from) ;
      "url"       , e (#url) 
    ]
  end)

  module LikeYourItem = MakeDual(struct
    type t = <
      fullname : string ;
      instance : string ;
      from     : string ;
      url      : string 
    > ;;
    let title        = "mail.notify.like_item.subject" 
    let source       = "like_your_item"
    let mapping ~esc l = 
      let e = if esc then Mk.esc else Mk.str in [ 
      "fullname"  , e (#fullname) ;
      "instance"  , e (#instance) ;
      "from"      , e (#from) ;
      "url"       , e (#url) 
    ]
  end)

  module LikeTheirItem = MakeDual(struct
    type t = <
      fullname : string ;
      instance : string ;
      from     : string ;
      url      : string 
    > ;;
    let title        = "mail.notify.like_item.subject" 
    let source       = "like_your_item"
    let mapping ~esc l = 
      let e = if esc then Mk.esc else Mk.str in [ 
      "fullname"  , e (#fullname) ;
      "instance"  , e (#instance) ;
      "from"      , e (#from) ;
      "url"       , e (#url) 
    ]
  end)

  module CommentItem = MakeDual(struct
    type t = <
      author   : string ;
      fullname : string ;
      instance : string ;
      from     : string ;
      text     : string ;
      url      : string 
    > ;;
    let title        = "mail.notify.comment_item.subject" 
    let source       = "comment_item"
    let mapping ~esc l =
      let e = if esc then Mk.esc else Mk.str in [ 
	"text"      , Mk.str (#text |- 
	    (if esc then VText.format ~icons:[] else VText.format_mail)) ;	
	"author"    , e (#author) ;
	"fullname"  , e (#fullname) ;
	"instance"  , e (#instance) ;
	"from"      , e (#from) ;
	"url"       , e (#url) 
      ]
  end)

  module CommentYourItem = MakeDual(struct
    type t = <
      fullname : string ;
      instance : string ;
      from     : string ;
      text     : string ;
      url      : string 
    > ;;
    let title        = "mail.notify.comment_item.subject" 
    let source       = "comment_your_item"
    let mapping ~esc l =
      let e = if esc then Mk.esc else Mk.str in [ 
      "fullname"  , e (#fullname) ;
      "instance"  , e (#instance) ;
      "from"      , e (#from) ;
      "text"      , Mk.str (#text |- 
	  (if esc then VText.format ~icons:[] else VText.format_mail)) ;
      "url"       , e (#url) 
    ]
  end)

  module CommentTheirItem = MakeDual(struct
    type t = <
      fullname : string ;
      instance : string ;
      from     : string ;
      text     : string ;
      url      : string 
    > ;;
    let title        = "mail.notify.comment_item.subject" 
    let source       = "comment_your_item"
    let mapping ~esc l =
      let e = if esc then Mk.esc else Mk.str in [ 
	"text"      , Mk.str (#text |- 
	    (if esc then VText.format ~icons:[] else VText.format_mail)) ;
	"fullname"  , e (#fullname) ;
	"instance"  , e (#instance) ;
	"from"      , e (#from) ;
	"url"       , e (#url) 
      ]
  end)

  module BecomeMember = MakeDual(struct
    type t = <
      fullname : string ;
      instance : string ;
      from     : string ;
      url      : string 
    > ;;
    let title        = "mail.notify.become_member.subject" 
    let source       = "become_member"
    let mapping ~esc l =
      let e = if esc then Mk.esc else Mk.str in [ 
      "fullname"  , e (#fullname) ;
      "instance"  , e (#instance) ;
      "from"      , e (#from) ;
      "url"       , e (#url) 
    ]
  end)

  module VJoin = struct

    let _become_member = 
      let _fr = load "join-become_member-fr" [
	"fullname"  , Mk.str (#fullname) ;
	"instance"  , Mk.str (#instance) ;
	"from"      , Mk.str (#from) ;
	"url"       , Mk.str (#url) 
      ] `Text in
      function `Fr -> _fr
	
    let become_member ~fullname ~instance ~from ~url ~i18n ctx = 
      let template = _become_member (I18n.language i18n) in
      to_text template (object
	method fullname  = fullname
	method instance  = instance
	method from      = from
	method url       = url
      end) i18n ctx

  end

  module BecomeAdmin = MakeDual(struct
    type t = <
      fullname : string ;
      instance : string ;
      from     : string ;
      url      : string 
    > ;;
    let title        = "mail.notify.become_admin.subject" 
    let source       = "become_admin"
    let mapping ~esc l =
      let e = if esc then Mk.esc else Mk.str in [ 
      "fullname"  , e (#fullname) ;
      "instance"  , e (#instance) ;
      "from"      , e (#from) ;
      "url"       , e (#url) 
    ]
  end)
end

module SignupConfirm = MakeDual(struct
  type t = <
    fullname : string ;
    email    : string ;
    url      : string
  > ;;
  let title        = "mail.user-confirm.subject"
  let source       = "confirm"
  let mapping ~esc l =
    let e = if esc then Mk.esc else Mk.str in [
    "fullname"  , e (#fullname) ;
    "email"     , e (#email) ;
    "url"       , e (#url) 
  ]
end)

module PasswordReset = MakeDual(struct
  type t = <
    fullname : string ;
    email    : string ;
    url      : string
  > ;;
  let title = "mail.user-reset.subject"
  let source = "reset"
  let mapping ~esc l = 
    let e = if esc then Mk.esc else Mk.str in [
      "fullname"  , e (#fullname) ;
      "email"     , e (#email) ;
      "url"       , e (#url) 
  ]
end)

module Digest = struct

  module NextItem = MakeDual(struct
    type t = <
      url   : string ;
      time  : float ;
      title : string
    > ;;
    let title          = "" 
    let source         = "digest_item_next"
    let mapping ~esc l = 
      let e = if esc then Mk.esc else Mk.str in [ 
      "url",   e        (#url) ;
      "time",  Mk.itext (#time |- VDate.mdy_render) ; 
      "title", e        (#title)
    ] 
  end)
    
  module Via = MakeDual(struct
    type t = string * string
    let title          = "" 
    let source         = "digest_item_via"
    let mapping ~esc _ = 
      let e = if esc then Mk.esc else Mk.str in [
	"url",  e fst ;
	"name", e snd
      ] 
  end)

  module Item = MakeDual(struct
    type t = <
      from      : string ;
      from_url  : string ;
      via       : Via.t option ;
      url       : string ;
      time      : float ;
      text_body : string ;
      html_body : string ;
      title     : string ;
      next      : NextItem.t list 
    > ;;
    let title          = "" 
    let source         = "digest_item"
    let mapping ~esc l = 
      let e = if esc then Mk.esc else Mk.str in [
      "from"    , e         (#from) ;
      "from-url", e         (#from_url) ;
      "url"     , e         (#url) ;
      "via"     , Mk.sub_or (#via) (Via.template esc l) Mk.empty ;
      "time"    , Mk.itext  (#time |- VDate.mdy_render) ;
      "text"    , Mk.str    (if esc then (#html_body) else (#text_body)) ;
      "title"   , e         (#title) ;
      "next"    , Mk.list   (#next) (NextItem.template esc l)  
    ]
  end)

  module Mail = MakeDual(struct
    type t = <
      fullname : string ;
      unsub    : string ;
      list     : Item.t list ;
    > ;; 
    let title          = "mail.digest.subject"
    let source         = "digest"
    let mapping ~esc l = 
      let e = if esc then Mk.esc else Mk.str in [
	"fullname",    e       (#fullname) ; 
	"unsubscribe", e       (#unsub) ;   
	"items",       Mk.list (#list) (Item.template esc l) 
      ]
  end)

end
