(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open Ohm.Util
open BatPervasives

let load name = MModel.Template.load "instance" name

module Loader = MModel.Template.MakeLoader(struct let from = "instance" end)

module Install = Loader.Html(struct
  type t = unit
  let source = function `Fr -> "install-fr"
  let mapping _ = []
end)

module Sidebar = Loader.Html(struct
  type t = <
    box        : string * string ;
    incentives : VIncentive.item list ;
    picture    : string ;
    name       : string ;
    message    : string ;
    sidebar    : VSidebar.Index.t ;
    home       : string ;
    follow     : I18n.html 
  > ;;
  let source  _ = "sidebar"
  let mapping l = [
    "incentives", Mk.ihtml  (#incentives |- VIncentive.render_block) ; 
    "message",    Mk.str    (#message) ;
    "name",       Mk.esc    (#name) ;
    "pic",        Mk.esc    (#picture) ;
    "home",       Mk.text   (#home |- JsBase.boxLoad |- JsBase.to_event) ;
    "sidebar",    Mk.sub    (#sidebar) (VSidebar.Index.template l) ;
    "contents",   Mk.html   (#box |- O.Box.draw_container) ;
    "follow",     Mk.ihtml  (#follow)
  ]
end)

module WhiteFooter = Loader.Html(struct
  type t = IInstance.t
  let source    = function `Fr -> "footer-white-fr"
  let mapping _ = [ "iid", Mk.esc IInstance.to_string ]
end)

module Footer = Loader.Html(struct
  type t = IInstance.t
  let source    = function `Fr -> "footer-fr"
  let mapping _ = [ "iid", Mk.esc IInstance.to_string ]
end)

module LightWarning = Loader.Html(struct
  type t = unit
  let source  _ = "index/light"
  let mapping _ = []
end)

module TrialWarning = Loader.Html(struct
  type t = unit
  let source  _ = "index/trial"
  let mapping _ = []
end)

let r =       
  let _r = 
    let _fr = load "index" [ 
      "light",   Mk.sub_or (fun x -> if x # light && not x # trial then Some () else None) 
	(LightWarning.template `Fr) (Mk.empty) ;
      "trial",   Mk.sub_or (fun x -> if x # trial then Some () else None) 
	(TrialWarning.template `Fr) (Mk.empty) ;
      "content", Mk.html  (fun _ -> O.Box.draw_container O.Box.root) ;
      "footer",  Mk.ihtml (#footer) 
    ] `Html in
    function `Fr -> _fr
  in
  fun ~white ~light ~trial ~iid ~i18n ctx ->
    let template = _r (I18n.language i18n) in
    let data = object
      method light  = light
      method trial  = trial
      method footer = if white then WhiteFooter.render iid else Footer.render iid 
    end in 
    to_html template data i18n ctx

let public = 
  let _public = 
    let _fr = load "public" [
      "content", Mk.ihtml (#content) ;
      "footer",  Mk.ihtml (#footer) ;
      "login",   Mk.esc   (#login) ;
      "asso",    Mk.esc   (#asso) ;
    ] `Html in
    function `Fr -> _fr
  in
  fun ~white ~content ~iid ~asso ~login ~i18n ctx ->
    let template = _public (I18n.language i18n) in
    let data = object
      method footer  = if white then WhiteFooter.render iid else Footer.render iid
      method content = content
      method login   = login
      method asso    = asso
    end in
    to_html template data i18n ctx

module Profile = struct

  module Address = Loader.Html(struct
    type t = string
    let source  _ = "profile/address"
    let mapping _ = [
      "text", Mk.esc identity ;
      "url",  Mk.esc (fun s -> "http://maps.google.fr/maps?f=q&q=" ^ Util.urlencode s)
    ]
  end)

  module Website = Loader.Html(struct
    type t = string
    let source  _ = "profile/website"
    let mapping _ = [
      "url", Mk.str VText.secure_link 
    ]
  end)

  module Facebook = Loader.Html(struct
    type t = string
    let source  _ = "profile/facebook"
    let mapping _ = [
      "url", Mk.str VText.secure_link
    ]
  end)

  module Twitter = Loader.Html(struct
    type t = string
    let source  _ = "profile/twitter"
    let mapping _ = [
      "url", Mk.str VText.secure_link 
    ]
  end)

  module Phone = Loader.Html(struct
    type t = string
    let source  _ = "profile/phone"
    let mapping _ = [
      "phone", Mk.esc identity
    ]
  end)

  module Contact = Loader.Html(struct
    type t = string
    let source  _ = "profile/contact"
    let mapping _ = [
      "url",   Mk.esc (fun s -> "mailto:" ^ s) ;
      "email", Mk.esc identity 
    ]
  end)

  module Tag = Loader.Html(struct
    type t = string
    let source  _ = "profile/tags/tag"
    let mapping _ = [
      "name", Mk.esc identity 
    ]
  end)

  module Tags = Loader.Html(struct
    type t = Tag.t list
    let source  _ = "profile/tags"
    let mapping l = [
      "tag", Mk.list identity (Tag.template l) ;
    ]
  end)

  module Index = Loader.JsHtml(struct
    type t = <
      address  : Address.t  option ;
      website  : Website.t  option ;
      contact  : Contact.t  option ;
      tags     : Tags.t     option ;
      facebook : Facebook.t option ;
      twitter  : Twitter.t  option ;
      phone    : Phone.t    option ;
      desc     : string ;
      enlarge  : string option ;
      feed     : string * string ;
      stats    : I18n.html 
    > ;;
    let source  _ = "profile"
    let mapping l = [
      "desc",     Mk.str (#desc |- VText.format) ;
      "address",  Mk.sub_or (#address)  ( Address.template l) Mk.empty ;
      "website",  Mk.sub_or (#website)  ( Website.template l) Mk.empty ;
      "contact",  Mk.sub_or (#contact)  ( Contact.template l) Mk.empty ;
      "facebook", Mk.sub_or (#facebook) (Facebook.template l) Mk.empty ;
      "twitter",  Mk.sub_or (#twitter)  ( Twitter.template l) Mk.empty ;
      "phone",    Mk.sub_or (#phone)    (   Phone.template l) Mk.empty ;
      "tags",     Mk.sub_or (#tags)     (    Tags.template l) Mk.empty ;
      "feed",     Mk.html   (#feed |- O.Box.draw_container) ;
      "stats",    Mk.ihtml  (#stats) ;
    ]
    let script  _ = Json_type.Build.([
      "enlarge", (#enlarge |- optional string)
    ])
  end)

end

module UnboundProfile = struct

  module Address = Loader.Html(struct
    type t = string
    let source  _ = "profile/address"
    let mapping _ = [
      "text", Mk.esc identity ;
      "url",  Mk.esc (fun s -> "http://maps.google.fr/maps?f=q&q=" ^ Util.urlencode s)
    ]
  end)

  module Website = Loader.Html(struct
    type t = string
    let source  _ = "unbound-profile/website"
    let mapping _ = [
      "url", Mk.str VText.secure_link 
    ]
  end)

  module Facebook = Loader.Html(struct
    type t = string
    let source  _ = "unbound-profile/facebook"
    let mapping _ = [
      "url", Mk.str VText.secure_link
    ]
  end)

  module Twitter = Loader.Html(struct
    type t = string
    let source  _ = "unbound-profile/twitter"
    let mapping _ = [
      "url", Mk.str VText.secure_link 
    ]
  end)

  module Phone = Loader.Html(struct
    type t = string
    let source  _ = "unbound-profile/phone"
    let mapping _ = [
      "phone", Mk.esc identity
    ]
  end)

  module Contact = Loader.Html(struct
    type t = string
    let source  _ = "unbound-profile/contact"
    let mapping _ = [
      "url",   Mk.esc (fun s -> "mailto:" ^ s) ;
      "email", Mk.esc identity 
    ]
  end)

  module Tag = Loader.Html(struct
    type t = string
    let source  _ = "unbound-profile/tags/tag"
    let mapping _ = [
      "name", Mk.esc identity 
    ]
  end)

  module Tags = Loader.Html(struct
    type t = Tag.t list
    let source  _ = "unbound-profile/tags"
    let mapping l = [
      "tag", Mk.list identity (Tag.template l) ;
    ]
  end)

  module Warning = Loader.Html(struct
    type t = unit
    let source    = function `Fr -> "unbound-profile-warning-fr"
    let mapping _ = []
  end)

  module Index = Loader.JsHtml(struct
    type t = <
      address  : Address.t  option ;
      website  : Website.t  option ;
      contact  : Contact.t  option ;
      tags     : Tags.t     option ;
      facebook : Facebook.t option ;
      twitter  : Twitter.t  option ;
      phone    : Phone.t    option ;
      desc     : string ;
      picture  : string ;
      name     : string ;
      follow   : I18n.html ;
      enlarge  : string option ;
      feed     : string * string ;
      stats    : I18n.html 
    > ;;
    let source  _ = "unbound-profile"
    let mapping l = [
      "name",     Mk.esc (#name) ;
      "follow",   Mk.ihtml  (#follow) ;
      "pic",      Mk.esc (#picture) ;
      "warning",  Mk.sub (fun _ -> ()) (Warning.template l) ;
      "desc",     Mk.str (#desc |- VText.format) ;
      "address",  Mk.sub_or (#address)  ( Address.template l) Mk.empty ;
      "website",  Mk.sub_or (#website)  ( Website.template l) Mk.empty ;
      "contact",  Mk.sub_or (#contact)  ( Contact.template l) Mk.empty ;
      "facebook", Mk.sub_or (#facebook) (Facebook.template l) Mk.empty ;
      "twitter",  Mk.sub_or (#twitter)  ( Twitter.template l) Mk.empty ;
      "phone",    Mk.sub_or (#phone)    (   Phone.template l) Mk.empty ;
      "tags",     Mk.sub_or (#tags)     (    Tags.template l) Mk.empty ;
      "feed",     Mk.html   (#feed |- O.Box.draw_container) ;
      "stats",    Mk.ihtml  (#stats) ;
    ]
    let script  _ = Json_type.Build.([
      "enlarge", (#enlarge |- optional string)
    ])
  end)

end

module PublicProfile = struct

  module Website = Loader.Html(struct
    type t = string
    let source  _ = "public-profile/website"
    let mapping _ = [
      "url", Mk.str VText.secure_link 
    ]
  end)

  module Facebook = Loader.Html(struct
    type t = string
    let source  _ = "public-profile/facebook"
    let mapping _ = [
      "url", Mk.str VText.secure_link
    ]
  end)

  module Twitter = Loader.Html(struct
    type t = string
    let source  _ = "public-profile/twitter"
    let mapping _ = [
      "url", Mk.str VText.secure_link 
    ]
  end)

  module Info = Loader.Html(struct
    type t = string
    let source    = function `Fr -> "public-profile-info-fr"
    let mapping _ = [ "name", Mk.esc identity ]
  end)

  module Subscribed = Loader.Html(struct
    type t = string
    let source    = function `Fr -> "public-profile-subscribed-fr"
    let mapping _ = [ "name", Mk.esc identity ]
  end)

  module Index = Loader.JsHtml(struct
    type t = <
      website    : Website.t  option ;
      facebook   : Facebook.t option ;
      twitter    : Twitter.t  option ;
      desc       : string ;
      picture    : string ;
      name       : string ;
      subscribe  : string ;
      feed       : View.html ;
      stats      : I18n.html ;
      email      : string option ;
      subscribed : bool  
    > ;;
    let source  _ = "public-profile"
    let mapping l = [
      "subscribe", Mk.esc    (#subscribe) ;
      "name",      Mk.esc    (#name) ;
      "pic",       Mk.esc    (#picture) ;
      "info",      Mk.ihtml  (fun x -> 
	(if x # subscribed then Subscribed.render else Info.render) (x#name)) ;
      "desc",      Mk.str    (#desc |- VText.format) ;
      "website",   Mk.sub_or (#website)  ( Website.template l) Mk.empty ;
      "facebook",  Mk.sub_or (#facebook) (Facebook.template l) Mk.empty ;
      "twitter",   Mk.sub_or (#twitter)  ( Twitter.template l) Mk.empty ;
      "feed",      Mk.html   (#feed) ;
      "stats",     Mk.ihtml  (#stats) ;
    ]
    let script  _ = Json_type.Build.([
      "email", (#email |- optional string)
    ]) 
  end)

end
