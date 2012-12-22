(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let make title endpoint owid = object
  method title = (AdLib.get (title : O.i18n) : string O.boxrun) 
  method url   = Action.url endpoint owid ()
end

open UrlMe.Account

let make owid = object
  method home    = make `MeAccount_Page_Title    home    owid
  method admin   = make `MeAccount_Admin_Title   admin   owid
  method edit    = make `MeAccount_Edit_Title    edit    owid
  method pass    = make `MeAccount_Pass_Title    pass    owid
  method picture = make `MeAccount_Picture_Title picture owid
  method voeux   = make `MeAccount_Voeux_Title   voeux   owid
end
