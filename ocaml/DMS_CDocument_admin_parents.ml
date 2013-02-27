(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open DMS_CDocument_common

let make title endpoint key rid did = object
  method title = (AdLib.get (title : O.i18n) : string O.boxrun) 
  method url = 
    Action.url endpoint key [ IRepository.to_string rid ; 
			      IDocument.to_string did ]
end

open Url.Doc

let parents title key rid did = object
  method home    = object
    method title = return title 
    method url   = Action.url Url.file key [ IRepository.to_string rid ; 
					     IDocument.to_string did ]
  end
  method admin    = make `DMS_Document_Admin_Title    admin    key rid did 
end

