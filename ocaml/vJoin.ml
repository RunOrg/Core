(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open Ohm.Template
open BatPervasives

module Loader = MModel.Template.MakeLoader(struct let from = "join" end)

module Status = Loader.Text(struct

  let css = function
    | `NotMember
    | `Declined  -> "-not-member"
    | `Unpaid
    | `Pending   -> "-pending"
    | `Invited   -> "-invited"
    | `Member    -> "-member"

  let label state =
    let root = match state with
      | `NotMember -> "none"
      | `Pending   -> "to_validate"
      | `Invited   -> "invited"
      | `Unpaid    -> "unpaid"
      | `Declined  -> "denied"
      | `Member    -> "validated"
    in
    `label ("participate.state." ^ root)
 
  type t = MMembership.Status.t
  let source  _ = "status"
  let mapping _ = [
    "class", Mk.str  css ;
    "label", Mk.trad label
  ]

end)

module Self = struct

  module YesNoCancelButtons = Loader.Html(struct
    type t = <
      status : I18n.text ;
      yes    : I18n.text ;
      no     : I18n.text ; 
      no_js  : JsCode.t ;
    > ;;
    let source  _ = "buttons/yes-no-cancel"
    let mapping _ = [
      "status", Mk.trad (#status) ;
      "yes",    Mk.trad (#yes) ;
      "no",     Mk.trad (#no) ;
      "no-js",  Mk.text (#no_js |- JsBase.to_event) ;
    ]
  end)

  module YesCancelButtons = Loader.Html(struct
    type t = <
      status : I18n.text ;
      yes    : I18n.text ;
    > ;;
    let source  _ = "buttons/yes-cancel"
    let mapping _ = [
      "status", Mk.trad (#status) ;
      "yes",    Mk.trad (#yes) ;
    ]
  end)

  module NoCancelButtons = Loader.Html(struct
    type t = <
      status : I18n.text ;
      no     : I18n.text ; 
      no_js  : JsCode.t ;
    > ;;
    let source  _ = "buttons/no-cancel"
    let mapping _ = [
      "status", Mk.trad (#status) ;
      "no",     Mk.trad (#no) ;
      "no-js",  Mk.text (#no_js |- JsBase.to_event) ;
    ]
  end)

  let render_buttons ?yes ?no status = 
    match yes, no with 
      | None, None -> YesCancelButtons.render (object 
	method status = status
	method yes    = `label "save"
      end)
      | Some yes, None -> YesCancelButtons.render (object
	method status = status
	method yes    = yes
      end)
      | None, Some (no, js) -> NoCancelButtons.render (object
	method status = status
	method no     = no
	method no_js  = js
      end)
      | Some yes, Some (no, js) -> YesNoCancelButtons.render (object
	method status = status
	method yes    = yes
	method no     = no
	method no_js  = js
      end)

  module Form = Loader.Html(struct
    type t = I18n.html
    let source  _ = "form"
    let mapping _ = [ "buttons", Mk.ihtml identity ]
  end)	

end

module Button = struct

  let css : MMembership.Status.t -> string list = function 
    | `Unpaid
    | `Pending   -> [ "typwidth" ; "orange-button" ]
    | `Invited   -> [ "typwidth" ; "blue-button" ; "status-button" ]
    | `Declined
    | `NotMember -> [ "typwidth" ]
    | `Member    -> [ "typwidth" ; "green-button" ]

  let label :  MMembership.Status.t -> I18n.text = function
    | `Unpaid    -> `label "membership.button.unpaid"
    | `Pending   -> `label "membership.button.pending"
    | `Invited   -> `label "membership.button.invited"
    | `Declined
    | `NotMember -> `label "membership.button.register"
    | `Member    -> `label "membership.button.member"

  let render status url = 
    VCore.CustomButton.render (object
      method css   = css status 
      method label = label status
      method js    = Js.runFromServer url
    end)

end

module Manage = struct

  type action = <
    time    : float ;
    name    : string ;
    picture : string ;
    profile : string
  > ;;

  module Validation_Write = Loader.Html(struct
    type t = <
      yes : JsCode.t ;
      no  : JsCode.t 
    > ;;
    let source  _ = "manage/validation/write"
    let mapping _ = [
      "yes", Mk.text (#yes |- JsBase.to_event) ;
      "no" , Mk.text (#no  |- JsBase.to_event) 
    ]
  end)

  module Validation_Read_Details = Loader.Html(struct
    type t = action 
    let source  _ = "manage/validation/read/details"
    let mapping _ = [
      "author-pic",  Mk.esc   (#picture) ;
      "author-url",  Mk.esc   (#profile) ;
      "author-name", Mk.esc   (#name) ;
      "date",        Mk.itext (#time |- VDate.render) ;
    ]
  end)

  module Validation_Read = Loader.Html(struct
    type t = JsCode.t * bool * action option 
    let source  _ = "manage/validation/read"
    let mapping l = [
      "answer",      Mk.trad   (fun (_,choice,_) -> `label (if choice then "yes" else "no")) ;
      "details",     Mk.sub_or (fun (_,_,action) -> action) 
	(Validation_Read_Details.template l) (Mk.empty) ;
      "edit",        Mk.text (fun (edit,_,_) -> JsBase.to_event edit)
    ]
  end)

  module Validation = Loader.Html(struct
    type t = <
      action : action option ;
      status : bool ;
      yes    : JsCode.t ;
      no     : JsCode.t ;
      edit   : JsCode.t 
    > ;;
    let source  _ = "manage/validation"
    let mapping l = [
      "read", Mk.sub_or
	(fun x -> if x # status || x # action <> None 
	  then Some (x # edit, x # status, x # action)
	  else None) 
	(Validation_Read.template l) (Mk.empty);
      "write", Mk.sub_or 
	(fun x -> if x # status || x # action <> None 
	  then None 
	  else Some (x :> Validation_Write.t))
	(Validation_Write.template l) (Mk.empty) ;
    ]
  end) 

  module Member_Write = Loader.Html(struct
    type t = <
      yes : JsCode.t ;
      no  : JsCode.t 
    > ;;
    let source  _ = "manage/member/write"
    let mapping _ = [
      "yes", Mk.text (#yes |- JsBase.to_event) ;
      "no" , Mk.text (#no  |- JsBase.to_event) ;
    ]
  end)

  module Member_Read_Details = Loader.Html(struct
    type t = action 
    let source  _ = "manage/member/read/details"
    let mapping _ = [
      "author-pic",  Mk.esc   (#picture) ;
      "author-url",  Mk.esc   (#profile) ;
      "author-name", Mk.esc   (#name) ;
      "date",        Mk.itext (#time |- VDate.render) ;
    ]
  end)

  module Member_Read_Button = Loader.Html(struct
    type t = JsCode.t
    let source  _ = "manage/member/read/button"
    let mapping _ = [
      "edit", Mk.text JsBase.to_event
    ]
  end)

  module Member_Read = Loader.Html(struct
    type t = JsCode.t option * bool * action option
    let source  _ = "manage/member/read"
    let mapping l = [
      "answer",      Mk.trad (fun (_,choice,a) -> `label (if a = None 
	then "no-answer" 
	else if choice then "yes" else "no")) ;
      "details",     Mk.sub_or (fun (_,_,action) -> action)
	(Member_Read_Details.template l) (Mk.empty) ;
      "button",      Mk.ihtml  (fun (edit,_,_) i -> match edit with 
	| None      -> View.str "&nbsp;"
	| Some edit -> Member_Read_Button.render edit i)
    ]
  end)

  module Member = Loader.Html(struct
    type t = < 
      action : (bool * action) option ;
      edit   : JsCode.t option ;
      yes    : JsCode.t ;
      no     : JsCode.t ;
    > ;;
    let source  _ = "manage/member"
    let mapping l = [
      "read", Mk.sub 
	(fun x -> match x # action with 
	  | Some (c,a) -> x # edit, c,     Some a 
	  | None       -> x # edit, false, None) 
	(Member_Read.template l) ;
      "write", Mk.str (fun _ -> "")
    ]
  end)

  module Invite_Details = Loader.Html(struct
    type t = action
    let source  _ = "manage/invite/details"
    let mapping _ = [
      "author-pic",  Mk.esc   (#picture) ;
      "author-url",  Mk.esc   (#profile) ;
      "author-name", Mk.esc   (#name) ;
      "date",        Mk.itext (#time |- VDate.render) ;
    ]
  end)

  module Invite_Button = Loader.Html(struct
    type t = JsCode.t * I18n.text 
    let source  _ = "manage/invite/button"
    let mapping _ = [
      "invite",       Mk.text (fst |- JsBase.to_event) ;
      "invite-label", Mk.trad snd
    ]
  end)

  module Invite = Loader.Html(struct
    type t = <
      action : action option ;
      invite : JsCode.t option 
    > ;;
    let source  _ = "manage/invite"
    let mapping l = [
      "button", Mk.ihtml begin fun x i c -> 
	let label = `label (if x # action = None 
	  then "membership.invite"
	  else "membership.reinvite")
	in
	match x # invite with 
	  | Some js -> Invite_Button.render (js,label) i c 
	  | None    -> View.str "&nbsp;" c
      end ;
      "current", Mk.trad 
	(fun x -> `label (if x # action = None then "no" else "")) ;
      "details", Mk.sub_or (#action) (Invite_Details.template l) (Mk.empty) ;
    ]
  end)

  module Data_Item = Loader.Html(struct
    type t = I18n.text * I18n.html
    let source  _ = "manage/data/items"
    let mapping _ = [
      "label", Mk.trad  fst ;
      "value", Mk.ihtml snd
    ]
  end)

  module Data = Loader.Html(struct
    type t = <
      items : (I18n.text * I18n.html) list ;
      edit  : JsCode.t
    > ;;
    let source  _ = "manage/data"
    let mapping l = [
      "items", Mk.list (#items) (Data_Item.template l) ;
      "edit",  Mk.text (#edit |- JsBase.to_event)
    ]
  end)

  module Page = Loader.Html(struct
    type t = <
      back    : string ;
      picture : string ;
      profile : string ;
      name    : string ;
      status  : VStatus.t ;
      join    : MMembership.Status.t ;
      admin   : Validation.t ;
      member  : Member.t ;
      invite  : Invite.t option ;
      data    : Data.t option 
    > ;;
    let source  _ = "manage"
    let mapping l = [
      "back"       , Mk.esc    (#back);
      "validation" , Mk.sub    (#admin) (Validation.template l) ;
      "picture"    , Mk.esc    (#picture) ;
      "profile"    , Mk.esc    (#profile) ;
      "name"       , Mk.esc    (#name) ;
      "status-css" , Mk.esc    (#status |- VStatus.css_class) ;
      "status"     , Mk.trad   (#status |- VStatus.label) ;
      "join-status", Mk.trad   (#join   |- VLabel.of_status) ;
      "member"     , Mk.sub    (#member) (Member.template l) ;
      "invite"     , Mk.sub_or (#invite) (Invite.template l) (Mk.empty) ;
      "data"       , Mk.sub_or (#data) (Data.template l) (Mk.empty) ;
    ]
  end)

end

