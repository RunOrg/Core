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
		     nonePublic ()
    | None -> let! entities = ohm $ MEntity.All.get_public iid `Group in
	      match entities with 
		| [] -> nonePublic () 
		| [entity] -> let eid = MEntity.Get.id entity in 
			      return $ Action.redirect (Action.url UrlClient.join key (Some (IEntity.decay eid))) res
		| list -> let! cuid = req_or (login ()) cuid in 		
			  pickPublic cuid list

end
