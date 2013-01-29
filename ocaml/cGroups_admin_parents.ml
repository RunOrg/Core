(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let make title endpoint key gid = object
  method title = (AdLib.get (title : O.i18n) : string O.boxrun) 
  method url = 
    Action.url endpoint key [ IGroup.to_string gid ]
end

open UrlClient.Members

let parents title key gid = object
  method home    = object
    method title = return title 
    method url   = Action.url home key [ IGroup.to_string gid ]
  end
  method admin    = make `Group_Admin_Title    admin    key gid 
  method edit     = make `Group_Edit_Title     edit     key gid 
  method people   = make `Group_People_Title   people   key gid 
  method invite   = make `Group_Invite_Title   invite   key gid 
  method jform    = make `Group_JoinForm_Title jform    key gid
  method cols     = make `Group_Columns_Title  cols     key gid 
  method delete   = make `Group_Delete_Title   delete   key gid
  method delegate = make `Group_Delegate_Title delegate key gid
  method delpick  = make `Group_DelPick_Title  delpick  key gid
end

