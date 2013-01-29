(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let make title endpoint key did = object
  method title = (AdLib.get (title : O.i18n) : string O.boxrun) 
  method url = 
    Action.url endpoint key [ IDiscussion.to_string did ]
end

open UrlClient.Discussion

let parents title key did = object
  method home    = object
    method title = return title 
    method url   = Action.url see key [ IDiscussion.to_string did ]
  end
  method admin    = make `Discussion_Admin          admin    key did 
  method edit     = make `Discussion_Edit_Title     edit     key did 
  method delete   = make `Discussion_Delete_Title   delete   key did
end

