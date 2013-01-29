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
    CPageLayout.core (snd key) (`Join_Public_Title (instance # name)) html res
  in

  let nonePublic () = 
    display $ Asset_Join_PublicNone.render (AdLib.get `Join_PublicNone_Title) 
  in

  let login () = 
    return $ Action.redirect (Action.url UrlLogin.login (snd key) (UrlLogin.save_url ~iid [])) res
  in

  let displayGroup cuid group =

    let! fields = ohm begin
      let  asid = MGroup.Get.group group in 
      let! avset = ohm_req_or (return []) $ MAvatarSet.naked_get asid in 
      MAvatarSet.Fields.flatten asid
    end in 

    let! token, status = ohm begin

      (* Acting as confirmed user to determine current status, if any *)
      let  self  = IUser.Assert.is_self (IUser.Deduce.is_anyone cuid) in 
      let! aid   = ohm_req_or (return (false,`NotMember)) $ MAvatar.find iid self in 
      let! actor = ohm_req_or (return (false,`NotMember)) $ MAvatar.actor (IAvatar.Assert.is_self aid) in
      let! ()    = true_or (return (true,`Member)) (MActor.member actor = None) in

      let  asid = MGroup.Get.group group in
      let! mid  = ohm $ MMembership.as_user asid actor in
      let! membership = ohm_req_or (return (false,`NotMember)) $ MMembership.get mid in
      return (false,membership.MMembership.status)
    end in 

    match status with 
      | `Member when token -> let url = Action.url UrlClient.intranet key [] in
			      display $ Asset_Join_PublicConfirmed.render url
      | `Member -> display $ Asset_PageLayout_Reload.render (object method time = 10.0 end)
      | `Pending -> display $ Asset_Join_PublicRequested.render ()
      | _ -> let url = Action.url UrlClient.doJoin key (IGroup.decay $ MGroup.Get.id group) in
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
    let! list = ohm $ Run.list_map (fun group ->
      let! name = ohm $ MGroup.Get.fullname group in
      let  url  = Action.url UrlClient.join key (Some (IGroup.decay (MGroup.Get.id group))) in
      return (object
	method name = name
	method url  = url
      end)
    ) list in
    display $ Asset_Join_PublicPick.render list
  in

  let  eid    = req # args in 
  let! entity = ohm $ Run.opt_bind MGroup.get eid in 

  match entity with 
    | Some entity -> let! cuid = req_or (login ()) cuid in 		     
		     displayGroup cuid entity
    | None -> let! entities = ohm $ MGroup.All.visible iid in
	      match entities with 
		| [] -> nonePublic () 
		| [entity] -> let eid = MGroup.Get.id entity in 
			      return $ Action.redirect (Action.url UrlClient.join key (Some (IGroup.decay eid))) res
		| list -> let! cuid = req_or (login ()) cuid in 		
			  pickPublic cuid list

end

let () = UrlClient.def_doJoin begin fun req res ->

  let panic = return $ Action.javascript (Js.reload ()) res in

  let! json = req_or panic $ Action.Convenience.get_json req in 

  let! cuid, key, iid, instance = CClient.extract req res in  
  let! cuid = req_or panic cuid in 

  (* Creating an avatar and loading the actor for that avatar. *)
  let! aid = ohm $ MAvatar.become_contact iid (IUser.Deduce.is_anyone cuid) in
  let! actor = ohm_req_or panic $ MAvatar.actor (IAvatar.Assert.is_self aid) in 

  let  eid = req # args in
  let! entity = ohm_req_or panic $ MGroup.view eid in 
  let  gid = MGroup.Get.group entity in
  let! group = ohm_req_or panic $ MAvatarSet.naked_get gid in 

  let! fields = ohm $ MAvatarSet.Fields.flatten gid in

  if fields = [] then 

    let! () = ohm $ MMembership.user gid actor true in
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
    
    let! () = ohm $ MMembership.user gid actor true in
    let! () = ohm $ Self.save_data actor result in 

    return $ Action.javascript (Js.reload ()) res


end
