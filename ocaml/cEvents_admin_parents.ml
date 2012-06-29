(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let make title endpoint key eid = object
  method title = (AdLib.get (title : O.i18n) : string O.boxrun) 
  method url   = Action.url endpoint key [ IEntity.to_string eid ]
end

open UrlClient.Events

let home    name key eid = make name                 home    key eid
let admin        key eid = make `Event_Admin_Title   admin   key eid
let edit         key eid = make `Event_Edit_Title    edit    key eid
let picture      key eid = make `Event_Picture_Title picture key eid
let people       key eid = make `Event_People_Title  people  key eid 
let access       key eid = make `Event_Access_Title  access  key eid
