(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module FormFmt = Fmt.Make(struct
  type json t = <
    name : string ;
    template : ITemplate.Event.t ;
    pic : string option ;
  >
end)

let () = CClient.define UrlClient.Events.def_create begin fun access -> 

  let forbidden = O.Box.fill begin
    let url = Action.url UrlClient.Events.home (access # instance # key) [] in
    Asset_Event_CreateForbidden.render (object method url = url end) 
  end in

  let! iid = ohm_req_or forbidden $ O.decay (MInstanceAccess.can_create_event (access # actor)) in

  let! create = O.Box.react Ohm.Fmt.Unit.fmt begin fun () json _ res -> 

    let! post = req_or (return res) $ FormFmt.of_json_safe json in 

    let! pic = ohm $ O.decay begin 
      let! pic = req_or (return None) (post # pic) in
      let! fid, _ = req_or (return None) (try Some (BatString.split pic "/") with _ -> None) in
      MOldFile.instance_pic iid (IFile.of_string fid) 
    end in    

    let name = match BatString.strip (post # name) with 
      | "" -> None
      | str -> Some str
    in

    let! eid = ohm $ O.decay (MEvent.create ~self:(access # actor) ~name ?pic ~iid (post # template)) in

    let  url = Action.url UrlClient.Events.edit (access # instance # key) [ IEvent.to_string eid ] in

    return $ Action.javascript (Js.redirect url ()) res

  end in

  O.Box.fill $ O.decay begin

    let templates = 
      List.map (fun tid -> (object
	method name  = PreConfig_Template.Events.name tid
	method desc  = PreConfig_Template.Events.desc tid 
	method value = ITemplate.Event.to_string tid 
      end))
	(PreConfig_Vertical.events (access # instance # ver)) 
    in

    Asset_Event_Create.render (object
      method url = JsCode.Endpoint.to_json (OhmBox.reaction_endpoint create ())
      method templates = templates
      method upload = Action.url UrlUpload.Client.root (access # instance # key) ()
      method pics   = Action.url UrlUpload.Client.find (access # instance # key) ()
      method back   = Action.url UrlClient.Events.home (access # instance # key) []
    end)

  end
end
