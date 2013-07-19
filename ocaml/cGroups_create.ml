(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module FormFmt = Fmt.Make(struct
  type json t = <
    name : string ;
    template : ITemplate.Group.t ;
   ?access : [ `Public | `Normal | `Private ] = `Normal ;
  >
end)

let () = CClient.define_admin UrlClient.Members.def_create begin fun access -> 

  let iid = IInstance.Deduce.admin_create_group (access # iid) in

  let! create = O.Box.react Ohm.Fmt.Unit.fmt begin fun () json _ res -> 

    let! post = req_or (return res) $ FormFmt.of_json_safe json in 

    let name = BatString.strip (post # name) in

    let! gid = ohm $ MGroup.create 
      ~self:(access # actor) ~name ~iid ~vision:(post # access) (post # template) in

    let  url = Action.url UrlClient.Members.invite (access # instance # key) [ IGroup.to_string gid ] in

    return $ Action.javascript (Js.redirect url ()) res

  end in

  O.Box.fill $ O.decay begin

    let templates = 
      List.map (fun tid -> (object
	method name  = PreConfig_Template.Groups.name tid
	method desc  = PreConfig_Template.Groups.desc tid 
	method value = ITemplate.Group.to_string tid 
      end))
	(PreConfig_Vertical.groups (access # instance # ver)) 
    in

    let values = List.map (fun (str,label,tag) -> (object
      method value = str
      method label = label
      method tag   = tag
      method check = label = `Normal 
    end)) [
      "Public",  `Public,  Some `Website ;
      "Normal",  `Normal,  None ;
      "Private", `Private, Some `Secret
    ] in

    Asset_Group_Create.render (object
      method url        = JsCode.Endpoint.to_json (OhmBox.reaction_endpoint create ())
      method templates  = templates
      method visibility = values
      method back       = Action.url UrlClient.Members.home (access # instance # key) []
    end)

  end
end
