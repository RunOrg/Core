(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let make title endpoint key eid = object
  method title = (AdLib.get (title : O.i18n) : string O.boxrun) 
  method url = 
    Action.url endpoint key [ IEntity.to_string eid ]
end

open UrlClient.Forums

let parents title key eid = object
  method home    = object
    method title = return title 
    method url   = Action.url see key [ IEntity.to_string eid ]
  end
  method admin   = make `Forum_Admin_Title   admin    key eid 
  method edit    = make `Forum_Edit_Title    edit     key eid 
  method people  = make `Forum_People_Title  people   key eid 
end

