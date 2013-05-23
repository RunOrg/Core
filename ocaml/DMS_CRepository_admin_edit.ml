(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open DMS_CRepository_common
open DMS_CRepository_admin_common

let template allm_gid gid_by_asid groups = 

  let gid_by_asid asid = try Some (List.assoc asid gid_by_asid) with Not_found -> None in

  let inner = 
    OhmForm.begin_object (fun ~name ~groups ~upload -> (object
      method name   = name
      method groups = groups 
      method upload = upload
    end))
      
    |> OhmForm.append (fun f name -> return $ f ~name) 
	(VEliteForm.text
	   ~label:(AdLib.get `DMS_Repo_Field_Name)
	   (fun repo -> return (MRepository.Get.name repo)) 
	   (OhmForm.required (AdLib.get `DMS_Field_Required)))

    |> OhmForm.append (fun f groups -> return $ f ~groups) 
	(VEliteForm.picker
	   ~label:(AdLib.get `DMS_Repo_Field_Vision)
	   ~format:IGroup.fmt
	   ~static:groups
	   (fun repo -> match MRepository.Get.vision repo with 
	   | `Normal -> return (BatList.filter_map identity [allm_gid])
	   | `Private asids -> return (BatList.filter_map gid_by_asid asids)) 
	   (fun f gids -> return (Ok gids)))
	
    |> OhmForm.append (fun f upload -> return $ f ~upload) 
	(VEliteForm.radio
	   ~label:(AdLib.get `DMS_Repo_Field_Upload)
	   ~format:Fmt.Bool.fmt
	   ~source:[ true,  AdLib.write `DMS_Repo_Upload_Viewers ;
		     false, AdLib.write `DMS_Repo_Upload_List ]
	   (fun repo -> match MRepository.Get.upload repo with 
	   | `Viewers -> return (Some true)
	   | `List _ -> return (Some false)) 
	   (fun f sel -> return (Ok (sel <> Some false))))	
  in

  let html = Asset_Discussion_Create.render () in

  OhmForm.wrap "" html inner


let () = define Url.Repo.def_edit begin fun parents repo access -> 

  let! save = O.Box.react Fmt.Unit.fmt begin fun _ json _ res ->

    let template = template None [] [] in
    let src = OhmForm.from_post_json json in 
    let form = OhmForm.create ~template ~source:src in 
    
    (* Extract the results from the form *)

    let fail errors = 
      let  form = OhmForm.set_errors errors form in 
      let! json = ohm (OhmForm.response form) in
      return (Action.json json res) 
    in

    let! result = ohm_ok_or fail (OhmForm.result form) in 

    (* Save the changes to the database *) 

    let  gids = result # groups in 
    let! groups = ohm $ Run.list_filter begin fun gid -> 
      let! group = ohm_req_or (return None) $ MGroup.view ~actor:(access # actor) gid in 
      return $ Some group
    end gids in 

    let! all_members = ohm $ Run.list_exists MGroup.Get.is_all_members groups in 
    let  vision = if all_members then `Normal else `Private (List.map MGroup.Get.group groups) in

    let name   = result # name in
    let upload = if result # upload then `Viewers else `List in 

    let! () = ohm (MRepository.Set.info ~name ~vision ~upload repo (access # actor)) in

    (* Redirect to main page *)

    let  rid = MRepository.Get.id repo in 
    let  url = Action.url Url.see (access # instance # key) [ IRepository.to_string rid ] in

    return $ Action.javascript (Js.redirect url ()) res

  end in    

  O.Box.fill $ O.decay begin 

    let wrap body = 
      Asset_Admin_Page.render (object
	method parents = [ parents # home ; parents # admin ] 
	method here = parents # edit # title
	method body = body
      end)
    in  

    let! list = ohm (MGroup.All.visible ~actor:(access # actor) (access # iid)) in
    let! groups = ohm $ Run.list_map (fun group -> 
      let! name = ohm $ MGroup.Get.fullname group in 
      let  asid = MGroup.Get.group group in 
      let  gid  = IGroup.decay (MGroup.Get.id group) in
      let! allm = ohm (MGroup.Get.is_all_members group) in 
      return (asid, allm, (gid, name, return (Html.esc name))) 
    ) list in 

    let allm_gid = 
      try let _, _, (gid,_,_) = List.find (fun (_,allm,_) -> allm) groups in
	  Some gid
      with Not_found -> None in
    
    let gid_by_asid = 
      List.map (fun (asid,_,(gid,_,_)) -> asid, gid) groups in 
    
    let groups = 
      List.map (fun (_,_,g) -> g) groups in 

    let template = template allm_gid gid_by_asid groups in
    let form = OhmForm.create ~template ~source:(OhmForm.from_seed repo) in
    let url  = OhmBox.reaction_endpoint save () in
    
    wrap (Asset_EliteForm_Form.render (OhmForm.render form url)) 

  end

end
