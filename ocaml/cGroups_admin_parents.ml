(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let make title endpoint key eid = object
  method title = (AdLib.get (title : O.i18n) : string O.boxrun) 
  method url = 
    Action.url endpoint key [ IEntity.to_string eid ]
end

open UrlClient.Members

let parents title key eid = object
  method home    = object
    method title = return title 
    method url   = Action.url home key [ IEntity.to_string eid ]
  end
  method admin   = make `Group_Admin_Title    admin   key eid 
  method edit    = make `Group_Edit_Title     edit    key eid 
  method people  = make `Group_People_Title   people  key eid 
  method invite  = make `Group_Invite_Title   invite  key eid 
  method jform   = make `Group_JoinForm_Title jform   key eid
  method cols    = make `Group_Columns_Title  cols    key eid 
end

