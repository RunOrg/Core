(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CGroups_admin_common

module PublishFmt = Fmt.Make(struct
  type json t = [ `Private | `Normal | `Public ]
end)

let template () = 

  let inner = 
    OhmForm.begin_object (fun ~name ~publish -> (object
      method name = name
      method publish = publish
    end))
      
    |> OhmForm.append (fun f name -> return $ f ~name) 
	(VEliteForm.text
	   ~label:(AdLib.get `Group_Edit_Name)
	   (fun (entity,_) -> let! name = req_or (return "") $ MEntity.Get.name entity in
			      TextOrAdlib.to_string name)
	   (OhmForm.required (AdLib.get `Group_Edit_Required)))
	
    |> OhmForm.append (fun f publish -> return $ f ~publish) 
	(VEliteForm.radio     
	   ~label:(AdLib.get `Group_Edit_Publish)
	   ~detail:(AdLib.get `Group_Edit_Publish_Detail)
	   ~format:PublishFmt.fmt
	   ~source:(List.map
		      (fun (stat, tag) -> stat, Asset_Event_StatusRadio.render (object
			method status = tag
			method label  = AdLib.get (`Group_Edit_Publish_Label stat)
		      end))
		      [ `Public,  Some `Website ;
			`Normal,  None ; 
			`Private, Some `Secret ])
	   (fun (entity,_) -> return $ Some (MEntity.Get.real_access entity))
	   OhmForm.keep)	
  in

  let html = Asset_Group_Edit.render () in
  OhmForm.wrap "" html inner

let () = define UrlClient.Members.def_edit begin fun parents entity access -> 
  
  let! save = O.Box.react Fmt.Unit.fmt begin fun _ json _ res -> 
    
    let  template = template () in
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

    let name = match BatString.strip result # name with 
      | "" -> None
      | str -> Some (`text str) 
    in

    let data = [] in
    
    let view = BatOption.default `Normal (result # publish) in

    let! () = ohm $ O.decay begin
      MEntity.try_update (access # self) entity ~draft:false ~name ~data ~view
    end in

    (* Redirect to main page *)

    let url = parents # home # url in 
    return $ Action.javascript (Js.redirect url ()) res

  end in   
  
  O.Box.fill begin 

    let! data = ohm begin
      let! t = ohm_req_or (return []) $ O.decay (MEntity.Data.get (MEntity.Get.id entity)) in
      return $ MEntity.Data.data t
    end in
      
    let template = template () in
    let form = OhmForm.create ~template ~source:(OhmForm.from_seed (entity,data)) in
    let url  = OhmBox.reaction_endpoint save () in
        
    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ] 
      method here = parents # edit # title
      method body = Asset_EliteForm_Form.render (OhmForm.render form url)
    end)

  end

end
