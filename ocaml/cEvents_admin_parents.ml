(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let make title endpoint key eid = object
  method title = (AdLib.get (title : O.i18n) : string O.boxrun) 
  method url = 
    Action.url endpoint key [ IEntity.to_string eid ]
end

open UrlClient.Events

let parents title key eid = object
  method home    = object
    method title = return title 
    method url   = Action.url see key [ IEntity.to_string eid ]
  end
  method admin    = make `Event_Admin_Title    admin    key eid 
  method edit     = make `Event_Edit_Title     edit     key eid 
  method picture  = make `Event_Picture_Title  picture  key eid 
  method people   = make `Event_People_Title   people   key eid 
  method delegate = make `Event_Delegate_Title delegate key eid 
  method invite   = make `Event_Invite_Title   invite   key eid 
  method jform    = make `Event_JoinForm_Title jform    key eid
  method cols     = make `Event_Columns_Title  cols     key eid 
  method delete   = make `Event_Delete_Title   delete   key eid
  method delpick  = make `Event_DelPick_Title  delpick  key eid
end

