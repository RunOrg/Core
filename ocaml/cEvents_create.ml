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

    let templates = 
      List.map (fun tid -> (object
	method name  = PreConfig_Template.name tid
	method desc  = PreConfig_Template.desc tid 
	method value = ITemplate.to_string tid 
      end))
	(PreConfig_Vertical.events (access # instance # ver)) 
    in

    Asset_Event_Create.render (object
      method url = "" 
      method templates = templates
      method upload = ""
      method pics = "" 
      method back = Action.url UrlClient.Events.home (access # instance # key) []
    end)

  end
end
