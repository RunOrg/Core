(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Self = CJoin_self

let template fields = Self.template `Join_Public_Save fields 

let () = UrlClient.def_join begin fun req res ->

  let! cuid, key, iid, instance = CClient.extract req res in

  let display main = 
    let left = CWebsite. Left.render cuid key iid in 
    let html = VNavbar.public `Join ~cuid ~left ~main instance in
    CPageLayout.core (`Join_Public_Title (instance # name)) html res
  in

  let nonePublic () = 
    display $ Asset_Join_PublicNone.render (AdLib.get `Join_PublicNone_Title) 
  in

  let login () = 
    return $ Action.redirect (Action.url UrlLogin.login () (UrlLogin.save_url ~iid [])) res
  in

  let displayEntity cuid entity =

    let! fields = ohm begin
      let  gid = MEntity.Get.group entity in 
      let! group = ohm_req_or (return []) $ MGroup.naked_get gid in 
      MGroup.Fields.flatten gid
    end in 

    let! token, status = ohm begin

      (* Acting as confirmed user to determine current status, if any *)
      let  self = IUser.Assert.is_self (IUser.Deduce.is_anyone cuid) in 
      let! isin = ohm $ MAvatar.identify_user iid self in 
      let! aid  = req_or (return (false,`NotMember)) (IIsIn.avatar isin) in
      let! ()   = true_or (return (true,`Member)) (IIsIn.Deduce.is_token isin = None) in

      let  gid  = MEntity.Get.group entity in
      let! mid  = ohm $ MMembership.as_user gid aid in
      let! membership = ohm_req_or (return (false,`NotMember)) $ MMembership.get mid in
      return (false,membership.MMembership.status)
    end in 

    match status with 
      | `Member when token -> let url = Action.url UrlClient.intranet key [] in
			      display $ Asset_Join_PublicConfirmed.render url
      | `Member -> display $ Asset_PageLayout_Reload.render (object method time = 10.0 end)
      | `Pending -> display $ Asset_Join_PublicRequested.render ()
      | _ -> let url = Action.url UrlClient.doJoin key (IEntity.decay $ MEntity.Get.id entity) in
	     if fields = [] then 
	       display $ Asset_Join_PublicNoFields.render (object method url = url end)
	     else
	       let template = template fields in 
	       let form = OhmForm.create ~template ~source:(OhmForm.empty) in
	       let url = JsCode.Endpoint.of_url url in 
	       display $ Asset_Join_Public.render (object 
		 method form = OhmForm.render form url 
	       end)

  in

  let pickPublic cuid list = 
    let! list = ohm $ Run.list_map (fun entity ->
      let! name = ohm $ CEntityUtil.name entity in 
      let  url  = Action.url UrlClient.join key (Some (IEntity.decay (MEntity.Get.id entity))) in
      return (object
	method name = name
	method url  = url
      end)
    ) list in
    display $ Asset_Join_PublicPick.render list
  in

  let  eid = req # args in 
  let! entity = ohm $ Run.opt_bind MEntity.get_if_public eid in 
  let  entity = BatOption.bind (fun entity -> if MEntity.Get.grants entity then Some entity else None) entity in

  match entity with 
    | Some entity -> let! cuid = req_or (login ()) cuid in 		     
		     displayEntity cuid entity
    | None -> let! entities = ohm $ MEntity.All.get_public iid `Group in
	      match entities with 
		| [] -> nonePublic () 
		| [entity] -> let eid = MEntity.Get.id entity in 
			      return $ Action.redirect (Action.url UrlClient.join key (Some (IEntity.decay eid))) res
		| list -> let! cuid = req_or (login ()) cuid in 		
			  pickPublic cuid list

end

let () = UrlClient.def_doJoin begin fun req res ->

  let panic = return $ Action.javascript (Js.reload ()) res in

  let! json = req_or panic $ Action.Convenience.get_json req in 

  let! cuid, key, iid, instance = CClient.extract req res in  
  let! cuid = req_or panic cuid in 

  let! aid = ohm $ MAvatar.self_become_contact iid cuid in

  let  eid = req # args in
  let! entity = ohm_req_or panic $ MEntity.get_if_public eid in 
  let! () = true_or panic (MEntity.Get.kind entity = `Group) in 
  let  gid = MEntity.Get.group entity in
  let! group = ohm_req_or panic $ MGroup.naked_get gid in 

  let! fields = ohm $ MGroup.Fields.flatten gid in

  if fields = [] then 

    let! () = ohm $ MMembership.user gid aid true in
    return $ Action.javascript (Js.reload ()) res 

  else 
    
    (* Extract form data *)
    
    let! json = req_or panic $ Action.Convenience.get_json req in
    
    let  src  = OhmForm.from_post_json json in 
    let  form = OhmForm.create ~template:(template fields) ~source:src in
    
    let fail errors = 
      let  form = OhmForm.set_errors errors form in
      let! json = ohm $ OhmForm.response form in
      return $ Action.json json res
    in
    
    let! result = ohm_ok_or fail $ OhmForm.result form in     

    (* Save the data and process the join request *)
    
    let! () = ohm $ MMembership.user gid aid true in
    let! () = ohm $ Self.save_data aid result in 

    return $ Action.javascript (Js.reload ()) res


end
