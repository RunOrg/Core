(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Url = DMS_Url
module IRepository = DMS_IRepository
module MRepository = DMS_MRepository

let template groups = 

  let inner = 
    OhmForm.begin_object (fun ~name ~groups ~upload -> (object
      method name   = name
      method groups = groups 
      method upload = upload
    end))
      
    |> OhmForm.append (fun f name -> return $ f ~name) 
	(VEliteForm.text
	   ~label:(AdLib.get `DMS_Repo_Field_Name)
	   (fun _ -> return "") 
	   (OhmForm.required (AdLib.get `DMS_Field_Required)))

    |> OhmForm.append (fun f groups -> return $ f ~groups) 
	(VEliteForm.picker
	   ~label:(AdLib.get `DMS_Repo_Field_Vision)
	   ~format:IGroup.fmt
	   ~static:groups
	   (fun _ -> return []) 
	   (fun f gids -> return (Ok gids)))
	
    |> OhmForm.append (fun f upload -> return $ f ~upload) 
	(VEliteForm.radio
	   ~label:(AdLib.get `DMS_Repo_Field_Upload)
	   ~format:Fmt.Bool.fmt
	   ~source:[ true,  AdLib.write `DMS_Repo_Upload_Viewers ;
		     false, AdLib.write `DMS_Repo_Upload_List ]
	   (fun _ -> return (Some true)) 
	   (fun f sel -> return (Ok (sel <> Some false))))	
  in

  let html = Asset_Discussion_Create.render () in

  OhmForm.wrap "" html inner

let () = CClient.define Url.def_create begin fun access ->
  
  let! save = O.Box.react Fmt.Unit.fmt begin fun _ json _ res -> 
    
    let  template = template [] in
    let  src  = OhmForm.from_post_json json in 
    let  form = OhmForm.create ~template ~source:src in
        
    (* Extract the result for the form *)
    
    let fail errors = 
      let  form = OhmForm.set_errors errors form in
      let! json = ohm $ OhmForm.response form in
      return $ Action.json json res
    in
    
    let! result = ohm_ok_or fail $ OhmForm.result form in  

    (* Save the changes to the database *)
    let gids   = result # groups in 
    let name   = result # name in
    let upload = if result # upload then `Viewers else `List in 

    let! groups = ohm $ Run.list_filter begin fun gid -> 
      let! group = ohm_req_or (return None) $ MGroup.view ~actor:(access # actor) gid in 
      return $ Some group
    end gids in 

    let! all_members = ohm $ Run.list_exists MGroup.Get.is_all_members groups in 
    let  vision = if all_members then `Normal else `Private (List.map MGroup.Get.group groups) in

    let  iid = access # iid in 

    let! rid = ohm $ MRepository.create ~self:(access # actor) ~name ~vision ~upload ~iid in

    (* Redirect to main page *)

    let  url = Action.url Url.see (access # instance # key) [ IRepository.to_string rid ] in

    return $ Action.javascript (Js.redirect url ()) res

  end in   
  
  O.Box.fill $ O.decay begin 

    let wrap body = 
      Asset_Admin_Page.render (object
	method parents = [] 
	method here = AdLib.get `DMS_NewRepo_Title
	method body = body
      end)
    in

    let! list = ohm $ MGroup.All.visible ~actor:(access # actor) (access # iid) in
    let! groups = ohm $ Run.list_map (fun group -> 
      let! name = ohm $ MGroup.Get.fullname group in 
      let  eid  = IGroup.decay (MGroup.Get.id group) in
      return (eid, name, return (Html.esc name)) 
    ) list in 

    let template = template groups in
    let form = OhmForm.create ~template ~source:(OhmForm.empty) in
    let url  = OhmBox.reaction_endpoint save () in
        
    wrap (Asset_EliteForm_Form.render (OhmForm.render form url))

  end

end

