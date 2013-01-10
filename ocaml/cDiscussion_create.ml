(* © 2012 RunOrg *)
open Ohm
open Ohm.Universal
open BatPervasives

module FormFmt = Fmt.Make(struct
  type json t = <
    title : string ;
    group : IEntity.t ;
    body  : string ; 
  >
end)

let () = CClient.define UrlClient.Discussion.def_create begin fun access -> 

  let! create = O.Box.react Ohm.Fmt.Unit.fmt begin fun () json _ res -> 

    let! post = req_or (return res) $ FormFmt.of_json_safe json in 
    let  title = post # title in
    let  body  = `Rich (MRich.parse (post # body)) in
    let  group = post # group in 

    let! group = ohm_req_or (return res) $ O.decay (MEntity.try_get (access # actor) group) in 
    let! group = ohm_req_or (return res) $ O.decay (MEntity.Can.view group) in
    let  gid   = MEntity.Get.group group in 

    let! did = ohm $ MDiscussion.create (access # actor) ~title ~body ~groups:[gid] in

    let  url = Action.url UrlClient.Discussion.see (access # instance # key) [ IDiscussion.to_string did ] in

    return $ Action.javascript (Js.redirect url ()) res

  end in

  O.Box.fill $ O.decay begin

    let! list = ohm $ MEntity.All.get_by_kind (access # actor) `Group in
    let! groups = ohm $ Run.list_map (fun group -> 
      let! name = ohm $ CEntityUtil.name group in 
      let  id   = IEntity.decay (MEntity.Get.id group) in
      return (object
	method name = name
	method id   = IEntity.to_string id
      end) 
    ) list in 
    
    Asset_Discussion_Create.render (object
      method url = JsCode.Endpoint.to_json (OhmBox.reaction_endpoint create ())
      method groups = groups
    end)

  end
end
