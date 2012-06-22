(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let () = CClient.define UrlClient.Events.def_create begin fun access -> 

  let forbidden = O.Box.fill begin
    let url = Action.url UrlClient.Events.home (access # instance # key) [] in
    Asset_Event_CreateForbidden.render (object method url = url end) 
  end in

  let! iid = ohm_req_or forbidden $ O.decay (MInstanceAccess.can_create_event access) in

  O.Box.fill $ O.decay begin

    Asset_Event_Create.render (object
      method url = "" 
      method templates = []
      method upload = ""
      method pics = "" 
      method back = Action.url UrlClient.Events.home (access # instance # key) []
    end)

  end
end
