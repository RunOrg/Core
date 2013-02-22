(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Url = DMS_Url
module MRepository = DMS_MRepository
module IRepository = DMS_IRepository

module Create = DMS_CRepository_create
module See    = DMS_CRepository_see

let render_repos ?start ~count access self = 

  let! repos, next = ohm $ MRepository.All.visible ~actor:(access # actor) ?start ~count (access # iid) in
  let  more = BatOption.map (fun next -> OhmBox.reaction_endpoint self next, Json.Null) next in 
  let  items = List.map begin fun repo -> 
    (object
      method name   = MRepository.Get.name repo
      method secret = MRepository.Get.vision repo <> `Normal
      method url    = Action.url Url.see (access # instance # key)
	[ IRepository.to_string (MRepository.Get.id repo) ]
     end)
  end repos in

  Asset_DMS_Home_Inner.render (object
    method items = items
    method more  = more
  end) 

let () = CClient.define Url.def_home begin fun access -> 
  
  let! more = O.Box.react IRepository.fmt begin fun start _ self res -> 
    let! html = ohm $ render_repos ~start ~count:8 access self in
    return $ Action.json [ "more", Html.to_json html ] res
  end in 
 
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
      method list   = render_repos ~count:0 access more 
    end)

  end 
end
