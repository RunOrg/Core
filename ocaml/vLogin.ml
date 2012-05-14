(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open Ohm.Template
open BatPervasives

let load name = MModel.Template.load "login" name

module Loader = MModel.Template.MakeLoader(struct let from = "login" end)

module Signup = 
struct

  let _success = 
    let _fr = load "signup-success-fr"  [ 
      "email", Mk.esc (#email) 
    ] `Html in
    function `Fr -> _fr
      
  let success ~email ~i18n =
    to_html
      (_success (I18n.language i18n))
      (object method email = email end) i18n

  let _taken = 
    let _fr = load "signup-taken-fr"  [ 
      "email", Mk.esc (#email) 
    ] `Html in
    function `Fr -> _fr
      
  let taken ~email ~i18n =
    to_html
      (_taken (I18n.language i18n))
      (object method email = email end) i18n

end

module Lost = 
struct

  let _success = 
    let _fr = load "lostpass-success-fr" [ 
      "email", Mk.esc (#email) 
    ] `Html in
    function `Fr -> _fr

  let success ~email ~i18n =
    to_html
      (_success (I18n.language i18n)) 
      (object method email = email end) i18n 

  let _form = 
    let mapping = [] 
      |> FLostpass.Form.to_mapping
	~prefix: "lost-form"
	~url:  (#url)
	~init: (#init) 
    in
    
    let _fr = load "lostpass" mapping `Html in
    
    function `Fr -> _fr

  let form
      ~url
      ~init
      ~i18n 
      (ctx:View.Context.box) =
    Template.to_html (_form (I18n.language i18n)) (object
      method url  = url
      method init = init
    end) i18n ctx

end

module Facebook = 
struct

  let _invalid = 
    let _fr = load "facebook-invalid-fr" [] `Html in
    function `Fr -> _fr

  let invalid ~i18n =
    to_html (_invalid (I18n.language i18n)) () i18n 

  let _not_found = 
    let _fr = load "facebook-not_found-fr" [] `Html in
    function `Fr -> _fr

  let not_found ~i18n =
    to_html (_not_found (I18n.language i18n)) () i18n 

  module Taken = Loader.Html(struct
    type t = <
      my_email : string ;
      their_email : string ;
      login_url : string
    > ;;
    let source = function `Fr -> "facebook-taken-fr"
    let mapping _ = [
      "my-email", Mk.esc (#my_email) ;
      "their-email", Mk.esc (#their_email) ;
      "login-url", Mk.esc (#login_url) 
    ]
  end)

end

let _login = 
  let mapping = VCore.head_mapping ()
    |> FLogin.Form.to_mapping 
      ~prefix:"login-form" 
      ~url:  (#login_url) 
      ~init: (#login_init)
    |> FSignup.Form.to_mapping
      ~prefix:"signup-form"
      ~url:  (#signup_url)
      ~init: (#signup_init)
    |> (fun map -> 
      (    "fb-url",     Mk.esc (#fb_url))
      :: ( "fb-channel", Mk.str (#fb_channel)) 
      :: ( "fb-app-id",  Mk.str (#fb_app_id))
      :: ( "name",       Mk.str (#name))
      :: ( "asso",       Mk.trad (fun x ->  
	match x # asso with 
	  | None -> `label "login.title"
	  | Some t -> `text t))
      :: map)
  in
  
  let _fr = load "index" mapping `Html in
  
  function `Fr -> _fr

let login 
    ~title 
    ~runorg_name
    ~asso
    ~login_url 
    ~login_init 
    ~signup_url 
    ~signup_init
    ~fb_url
    ~fb_channel
    ~fb_app_id
    ~lost_url
    ~lost_init 
    ~i18n ctx = 
  
  let ctx =
    let json str = Json_io.string_of_json ~recursive:true (Json_type.Build.string str) in
    to_html (_login (I18n.language i18n)) (object 
      method title       = title
      method asso        = asso
      method name        = runorg_name
      method login_url   = login_url
      method login_init  = login_init
      method signup_url  = signup_url
      method signup_init = signup_init
      method fb_url      = json fb_url
      method fb_channel  = json fb_channel
      method fb_app_id   = json fb_app_id
    end) i18n ctx
  in
  
  let lostpass = Lost.form ~url:lost_url ~init:lost_init ~i18n in
  let title = I18n.translate i18n (`label "login.lost-form.title") in
  
  View.Context.add_js_code 
    (Js.onClick "#lostpass-link" (Js.Dialog.create lostpass title)) 
    (ctx)

module Confirm = Loader.Html(struct
  type t = <
    name       : string ;
    title      : I18n.text ;
    fullname   : string ;
    inviter    : string ;
    email      : string ;
    image      : string ;
    url        : string ;
    init       : FConfirm.Form.t ;
    login_url  : string ;
    login_init : FLogin.Form.t ;
    fb_url     : string ;
    fb_channel : string ;
    fb_app_id  : string
  > ;;
  let source = function `Fr -> "notify-confirm-fr"
  let mapping _ = VCore.head_mapping ()
    |> FConfirm.Form.to_mapping 
      ~prefix:"confirm-form" 
      ~url:  (#url) 
      ~init: (#init)
    |> FLogin.Form.to_mapping 
      ~prefix:"login-form" 
      ~url:  (#login_url) 
      ~init: (#login_init)
    |> (fun l ->
      (    "fullname",   Mk.esc (#fullname) ) 
      :: ( "inviter",    Mk.esc (#inviter) )
      :: ( "email",      Mk.esc (#email) )
      :: ( "name",       Mk.str (#name) ) 
      :: ( "image",      Mk.esc (#image) )
      :: ( "fb-url",     Mk.esc (fun x -> Fmt.String.to_json_string (x # fb_url)) ) 
      :: ( "fb-channel", Mk.esc (fun x -> Fmt.String.to_json_string (x # fb_channel)) ) 
      :: ( "fb-app-id",  Mk.esc (#fb_app_id) )
      :: l )
end)

module Resend = Loader.Html(struct
  type t = string
  let source    = function `Fr -> "notify-resend-fr"
  let mapping _ = [ "name", Mk.str identity ]
end)
  

  
  
