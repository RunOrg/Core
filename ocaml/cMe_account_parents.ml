(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let make title endpoint = object
  method title = (AdLib.get (title : O.i18n) : string O.boxrun) 
  method url   = Action.url endpoint () ()
end

open UrlMe.Account

let home   = make `MeAccount_Page_Title  home
let admin  = make `MeAccount_Admin_Title admin
let edit   = make `MeAccount_Edit_Title  edit
let pass   = make `MeAccount_Pass_Title  pass
