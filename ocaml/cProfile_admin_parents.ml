(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let make title endpoint key aid = object
  method title = (AdLib.get (title : O.i18n) : string O.boxrun) 
  method url = 
    Action.url endpoint key [ IAvatar.to_string aid ]
end

open UrlClient.Profile

let parents title key aid = object
  method home    = object
    method title = return title 
    method url   = Action.url home key [ IAvatar.to_string aid ]
  end
  method admin    = make `Profile_Admin_Title    admin    key aid 
  method parents  = make `Profile_Parents_Title  parents  key aid
end

