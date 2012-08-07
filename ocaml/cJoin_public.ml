(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

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

    let! status = ohm begin

      (* Acting as confirmed user to determine current status, if any *)
      let  self = IUser.Assert.is_self (IUser.Deduce.is_anyone cuid) in 
      let! isin = ohm $ MAvatar.identify_user iid self in 
      let! aid  = req_or (return `NotMember) (IIsIn.avatar isin) in
      let! ()   = true_or (return `Member) (IIsIn.Deduce.is_token isin = None) in

      let  gid  = MEntity.Get.group entity in
      let! mid  = ohm $ MMembership.as_user gid aid in
      let! membership = ohm_req_or (return `NotMember) $ MMembership.get mid in
      return membership.MMembership.status 
    end in 

    match status with 
      | `Member -> let url = Action.url UrlClient.intranet key [] in
		   display $ Asset_Join_PublicConfirmed.render url
      | `Pending -> display $ Asset_Join_PublicRequested.render ()
      | _ -> display $ Asset_Join_PublicNoFields.render () 

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
