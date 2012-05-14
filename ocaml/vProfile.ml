(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open Ohm.Util
open BatPervasives

let load name = MModel.Template.load "profile" name

let _profile = 
  let _fr = load "info" [
    "email",     Mk.esc (#email) ;
    "birthdate", Mk.esc (#birthdate) ;
    "phone",     Mk.esc (#phone) ;
    "cellphone", Mk.esc (#cellphone) ;
    "address",   Mk.esc (#address) ;
    "zipcode",   Mk.esc (#zipcode) ;
    "city",      Mk.esc (#city) ;
    "country",   Mk.esc (#country) ;
    "gender",    Mk.str (#gender) 
  ] `Html in
  function `Fr -> _fr

let _empty = VCore.empty VIcon.Large.user (`label "profile.feed.empty")

let empty i18n ctx = 
  to_html _empty () i18n ctx

let _page = 
  let _fr = load "page" [
    "url-0",    Mk.esc    (#url_asso) ;
    "name-0",   Mk.esc    (#asso) ;
    "url-pic",  Mk.esc    (#pic) ;
    "name",     Mk.esc    (#name) ;
    "status",   Mk.trad   (fun x -> VStatus.label (x # status)) ;
    "url-1",    Mk.esc    (#above) ;
    "name-1",   Mk.i18n   (`label "menu.directory") ;
    "info",     Mk.sub_or (#info) (_profile `Fr) (Mk.empty) ;
    "feed",     Mk.html   (#feed) ;
    "actions",  Mk.ihtml  (#actions) ;
  ] `Html in 
  function `Fr -> _fr
    
let page ~actions ~profile ~url_asso ~asso ~url_above ~url_pic ~name ~status ~feed ~i18n ctx =
  let lang = I18n.language i18n in
  let opt  = function Some s -> s | None -> "" in
  let info = match profile with None -> None | Some profile ->
    Some MProfile.Data.(object
      method email     = opt (profile.email)
      method birthdate = opt (BatOption.map (MFmt.date_string lang) (profile.birthdate)) 
      method phone     = opt (profile.phone)
      method cellphone = opt (profile.cellphone)
      method address   = opt (profile.address)
      method zipcode   = opt (profile.zipcode) 
      method country   = opt (profile.country)
      method city      = opt (profile.city) 
      method gender    = match profile.gender with 
	| None -> ""
	| Some `m -> "<img src='"^VIcon.male^"'/>"
	| Some `f -> "<img src='"^VIcon.female^"'/>"
    end)	 
  in
  let template = _page lang in
  to_html template (object
    method asso      = asso
    method url_asso  = url_asso
    method pic       = url_pic
    method name      = name
    method status    = status
    method above     = url_above
    method info      = info
    method feed      = feed 
    method actions i18n ctx = VActionList.list ~list:actions ~i18n ctx
  end) i18n ctx

let _send_message = 
  let _any = load "send-message" begin
    []
    |> FProfile.SendMessage.Form.to_mapping
	~prefix:"send-message"
	~url:   (#form_url)
	~init:  (#form_init)
  end `Html in
  function `Fr -> _any
    
let send_message ~url ~init ~i18n ctx =
  to_html (_send_message (I18n.language i18n)) (object
    method form_url  = url
    method form_init = init
  end) i18n ctx
    
