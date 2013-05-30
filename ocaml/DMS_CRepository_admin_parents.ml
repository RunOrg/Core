(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open DMS_CRepository_common

let make title endpoint key rid = object
  method title = (AdLib.get (title : O.i18n) : string O.run) 
  method url = Action.url endpoint key [ IRepository.to_string rid ]
end

open Url.Repo

let parents title key rid = object
  method home    = object
    method title = return title 
    method url   = Action.url Url.see key [ IRepository.to_string rid ]	
  end
  method admin     = make `DMS_Repo_Admin_Title     admin    key rid
  method edit      = make `DMS_Repo_Edit_Title      edit     key rid
  method uploaders = make `DMS_Repo_Uploaders_Title uploader key rid
  method delpick   = make `DMS_Repo_Uploaders_Title delpick  key rid
  method advanced  = make `DMS_Repo_Advanced_Title  advanced key rid 
  method delete    = make `DMS_Repo_Delete_Title    delete   key rid
  method admins    = make `DMS_Repo_Admins_Title    admins   key rid
  method admpick   = make `DMS_Repo_Admins_Title    admpick  key rid 
end

  
