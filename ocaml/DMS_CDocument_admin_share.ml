(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open DMS_CDocument_common
open DMS_CDocument_admin_common

module ShareFmt = Fmt.Make(struct
  type json t = <
    id    : IRepository.t ;
    share : bool ; 
  >
end)

let is_shared repo shared_rids = 
  BatSet.mem (IRepository.decay (MRepository.Get.id repo)) shared_rids 

let allowed current_rid share repo = 
  if current_rid = IRepository.decay (MRepository.Get.id repo) then return false else 
    if share then
      let! _ = ohm_req_or (return false) (MRepository.Can.upload repo) in
      return true
    else 
      let! _ = ohm_req_or (return false) (MRepository.Can.remove repo) in
      return true    
	
let render current_rid shared_rids repo =
  let  shared  = is_shared repo shared_rids in 
  let  share   = not shared in 
  let! allowed = ohm (allowed current_rid share repo) in
  return (object
    method name    = MRepository.Get.name repo 
    method share   = share
    method allowed = allowed
    method id      = IRepository.to_string (MRepository.Get.id repo) 
  end)

let render_repos ?start ~count current_rid shared_rids access self = 

  let! repos, next = ohm $ MRepository.All.visible ~actor:(access # actor) ?start ~count (access # iid) in
  let  more = BatOption.map (fun next -> OhmBox.reaction_endpoint self next, Json.Null) next in 
  let! items = ohm $ Run.list_map (render current_rid shared_rids) repos in 

  Asset_DMS_Share_Inner.render (object
    method items = items
    method more  = more
  end)

let () = define Url.Doc.def_share begin fun parents rid doc access ->
  
  let shared_rids = 
    List.fold_left (fun s repo -> BatSet.add repo s) BatSet.empty
      (MDocument.Get.repositories doc)
  in 
  
  let! more = O.Box.react IRepository.fmt begin fun start _ self res ->
    let! html = ohm $ render_repos ~start ~count:8 rid shared_rids access self in
    return $ Action.json [ "more", Html.to_json html ] res
  end in
  
  let! post = O.Box.react Fmt.Unit.fmt begin fun _ args _ res ->

    let  fail = return (Action.javascript (Js.reload ()) res) in 

    let  respond allowed shared = 
      return (Action.json 
		[ "allowed", Json.Bool allowed ; 
		  "share",   Json.Bool (not shared) ] res)
    in

    let! args = req_or fail (ShareFmt.of_json_safe args) in
    let! repo = ohm_req_or fail (MRepository.get ~actor:(access # actor) (args # id)) in

    if args # share then
      let! rid' = ohm_req_or (respond false false) (MRepository.Can.upload repo) in
      let! () = ohm $ MDocument.Set.share rid' doc (access # actor) in
      let! allowed = ohm (allowed rid false repo) in
      respond allowed true
    else
      let! rid' = ohm_req_or (respond false true) (MRepository.Can.remove repo) in
      let! () = ohm $ MDocument.Set.unshare rid' doc (access # actor) in
      let! allowed = ohm (allowed rid false repo) in
      respond allowed false
      
  end in 
  
  O.Box.fill begin     
    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ]
      method here = parents # share # title
      method body = Asset_DMS_Share.render (object
	method list = render_repos ~count:0 rid shared_rids access more
	method post = JsCode.Endpoint.to_json (OhmBox.reaction_endpoint post ()) 
      end)
    end)
  end 
end
  
