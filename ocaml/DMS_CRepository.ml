(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Url = DMS_Url
module MRepository = DMS_MRepository

module Create = DMS_CRepository_create

let () = CClient.define Url.def_home begin fun access -> 
  O.Box.fill $ O.decay begin

    (* Can the user create a repository ? *)
    let admin = CAccess.admin access in 
    let create = 
      if admin = None then None
      else Some (Action.url Url.create (access # instance # key) []) 
    in     

    (* Render the page *)
    Asset_DMS_Home.render (object
      method create = create
    end)

  end 
end
