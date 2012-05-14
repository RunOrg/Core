(* © 2012 RUnOrg *)

open Ohm
open Ohm.Universal
open O
open BatPervasives

let confirm ctx label inner = 
  let name = "confirm-" ^ Box.string_of_reaction inner in
  O.Box.reaction name begin fun self bctx _ response ->
    let title = I18n.translate (ctx # i18n) (`label "confirm.title") in
    let view = VConfirm.ask label (bctx # reaction_url inner) (ctx # i18n) in
    return (Action.javascript (Js.Dialog.create view title) response) 
  end

let ask ctx label define callback = 
  let! inner   = define in
  let! confirm = confirm ctx label inner in
  callback confirm

