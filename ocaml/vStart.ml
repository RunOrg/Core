(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open Ohm.Util
open BatPervasives

module Loader = MModel.Template.MakeLoader(struct let from = "start" end)

module Hint = Fmt.Make(struct
  type json t = <
    selector "sel" : string ;
    hint           : string ;
    url            : string ;
    gravity        : [ `nw | `n | `ne | `e | `se | `s | `sw | `w ]
  >
end)

let hintlist list = 
  Json_type.Object begin 
    List.map 
      (fun (key,value) ->
	let key = match MStart.Step.to_json key with 
	  | Json_type.String s -> s
	  | _                  -> "-" 
	in
	key, Hint.to_json value) 
      list
  end

module type BLOCK = sig val name : string end

module Block = functor(B:BLOCK) -> Loader.Html(struct
  type t = string
  let source    = function `Fr -> "block-" ^ B.name ^ "-fr"
  let mapping _ = [ "nth", Mk.esc identity ] 
end)

module BuyBlock           = Block(struct let name = "buy" end)
module InviteMembersBlock = Block(struct let name = "invite" end)
module WritePostBlock     = Block(struct let name = "write" end)
module AddPictureBlock    = Block(struct let name = "picture" end)
module CreateEventBlock   = Block(struct let name = "event" end)
module InviteNetworkBlock = Block(struct let name = "network" end)
module AGBlock            = Block(struct let name = "ag" end)
module BroadcastBlock     = Block(struct let name = "broadcast" end)
module AGInviteBlock      = Block(struct let name = "ag-invite" end)

let render_step = function
  | `Buy           -> BuyBlock.render 
  | `InviteMembers -> InviteMembersBlock.render 
  | `WritePost     -> WritePostBlock.render
  | `AddPicture    -> AddPictureBlock.render
  | `CreateEvent   -> CreateEventBlock.render
  | `InviteNetwork -> InviteNetworkBlock.render
  | `Broadcast     -> BroadcastBlock.render
  | `AnotherEvent  -> (fun _ _ -> identity) 
  | `CreateAG      -> AGBlock.render
  | `AGInvite      -> AGInviteBlock.render

let render_steps steps i18n = 
  View.foreach (fun step -> render_step step (MStart.step_number step steps) i18n) steps

module Asso = Loader.JsHtml(struct
  type t = <
    hints : (MStart.Step.t * Hint.t) list ;
    steps :  MStart.Step.t list
  > ;;
  let source = function `Fr -> "asso-fr"
  let mapping _ = [
    "list", Mk.ihtml (#steps |- render_steps) 
  ]
  let script  _ = [
    "hints", (#hints |- hintlist)
  ]
end)

let hint i18n ~selector ~hint ~url ~gravity = object
  method selector = selector
  method hint     = I18n.translate i18n hint
  method url      = url
  method gravity  = gravity
end

let key_of_step : MStart.Step.t -> string = function
  | `InviteMembers -> "invite"
  | `WritePost     -> "write"
  | `AddPicture    -> "picture"
  | `CreateEvent   -> "event"
  | `AnotherEvent  -> "another-event"
  | `InviteNetwork -> "network"
  | `Buy           -> "buy"
  | `Broadcast     -> "broadcast"
  | `AGInvite      -> "ag.invite"
  | `CreateAG      -> "ag"

module TopBar = Loader.JsHtml(struct
  type t = <
    number : string ;
    text   : I18n.text ;
    more   : string ;
    action : I18n.text ;
    hint   : Hint.t ;
    step   : MStart.Step.t
  > ;;
  let source  _ = "top-bar"
  let mapping _ = [
    "number",   Mk.esc  (#number) ;
    "text",     Mk.trad (#text) ;
    "url-more", Mk.esc  (#more) ;
    "action",   Mk.trad (#action) ;
  ]
  let script  _ = [
    "hint",    (#hint |- Hint.to_json) ;
    "current", (#step |- MStart.Step.to_json)
  ]
end)
