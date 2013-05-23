(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open DMS_CRepository_common
open DMS_CRepository_admin_common

let template () = 

  let inner = 
    OhmForm.begin_object (fun ~remove ~detail -> (object
      method remove = remove
      method detail = detail
    end))
	
    |> OhmForm.append (fun f remove -> return $ f ~remove) 
	(VEliteForm.radio
	   ~label:(AdLib.get `DMS_Repo_Field_Remove)
	   ~format:Fmt.Bool.fmt
	   ~source:[ true,  AdLib.write `DMS_Repo_Remove_Free ;
		     false, AdLib.write `DMS_Repo_Remove_Restricted ]
	   (fun repo -> match MRepository.Get.remove repo with 
	   | `Free -> return (Some true)
	   | `Restricted -> return (Some false)) 
	   (fun f sel -> return (Ok (if sel <> Some false then `Free else `Restricted))))	

    |> OhmForm.append (fun f detail -> return $ f ~detail) 
	(VEliteForm.radio
	   ~label:(AdLib.get `DMS_Repo_Field_Detail)
	   ~format:Fmt.Bool.fmt
	   ~source:[ true,  AdLib.write `DMS_Repo_Detail_Public ;
		     false, AdLib.write `DMS_Repo_Detail_Private ]
	   (fun repo -> match MRepository.Get.detail repo with 
	   | `Public -> return (Some true)
	   | `Private -> return (Some false)) 
	   (fun f sel -> return (Ok (if sel <> Some false then `Public else `Private))))	

  in

  VEliteForm.with_ok_button ~ok:(AdLib.get `DMS_Repo_Save) inner

let () = define Url.Repo.def_advanced begin fun parents repo access -> 

  let! save = O.Box.react Fmt.Unit.fmt begin fun _ json _ res ->

    let template = template () in
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

    let  remove = result # remove in
    let  detail = result # detail in 
    let! () = ohm (MRepository.Set.advanced ~detail ~remove repo (access # actor)) in

    (* Redirect to main page *)

    let  rid = MRepository.Get.id repo in 
    let  url = Action.url Url.see (access # instance # key) [ IRepository.to_string rid ] in

    return $ Action.javascript (Js.redirect url ()) res

  end in    

  O.Box.fill $ O.decay begin 

    let wrap body = 
      Asset_Admin_Page.render (object
	method parents = [ parents # home ; parents # admin ] 
	method here = parents # advanced # title
	method body = body
      end)
    in  

    let template = template () in
    let form = OhmForm.create ~template ~source:(OhmForm.from_seed repo) in
    let url  = OhmBox.reaction_endpoint save () in
    
    wrap (Asset_EliteForm_Form.render (OhmForm.render form url)) 

  end

end
