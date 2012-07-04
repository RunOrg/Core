(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CEvents_admin_common

module PublishFmt = Fmt.Make(struct
  type json t = [ `Private | `Normal | `Public ]
end)

let template tmpl = 

  OhmForm.begin_object (fun ~name ~publish ~data -> (object
    method name = name
    method publish = publish
    method data = data
  end))
    
  |> OhmForm.append (fun f name -> return $ f ~name) 
      (VEliteForm.text
	 ~label:(AdLib.get `Event_Edit_Name)
	 (fun (entity,_) -> let! name = req_or (return "") $ MEntity.Get.name entity in
			    TextOrAdlib.to_string name)
	 (OhmForm.required (AdLib.get `Event_Edit_Required)))

  |> OhmForm.append (fun f publish -> return $ f ~publish) 
      (VEliteForm.radio     
	 ~label:(AdLib.get `Event_Edit_Publish)
	 ~detail:(AdLib.get `Event_Edit_Publish_Detail)
	 ~format:PublishFmt.fmt
	 ~source:(List.map
		    (fun (stat, tag) -> stat, Asset_Event_StatusRadio.render (object
		      method status = tag
		      method label  = AdLib.get (`Event_Edit_Publish_Label stat)
		    end)) 
		    [ `Public,  Some `Website ;
		      `Normal,  None ; 
		      `Private, Some `Secret ])
	 (fun (entity,_) -> return $ Some (MEntity.Get.real_access entity))
	 OhmForm.keep)
      
  |> OhmForm.append (fun f data -> return $ f ~data) 
      (List.fold_left (fun acc field -> 
	acc |> OhmForm.append (fun json result -> return $ (field # key,result) :: json) 
	    begin match field # edit with 
	      | `Input -> 
		(VEliteForm.text 
		   ~label:(AdLib.get (`PreConfig (field # label)))
		   ?detail:(BatOption.map (fun d -> AdLib.get (`PreConfig d)) (field # detail))
		   (fun (_,data) -> return begin 
		     try Json.to_string (List.assoc (field # key) data)
		     with _ -> ""
		   end) 
		   (OhmForm.keep))
	      | `Date -> 
		(VEliteForm.date 
		   ~label:(AdLib.get (`PreConfig (field # label)))
		   ?detail:(BatOption.map (fun d -> AdLib.get (`PreConfig d)) (field # detail))
		   (fun (_,data) -> return begin 
		     try Json.to_string (List.assoc (field # key) data)
		     with _ -> ""
		   end)		   		   
		   (OhmForm.keep))
	      | `Textarea ->
		(VEliteForm.textarea 
		   ~label:(AdLib.get (`PreConfig (field # label)))
		   ?detail:(BatOption.map (fun d -> AdLib.get (`PreConfig d)) (field # detail))
		   (fun (_,data) -> return begin 
		     try Json.to_string (List.assoc (field # key) data)
		     with _ -> ""
		   end)
		   (OhmForm.keep)) 
	    end
       ) (OhmForm.begin_object []) (PreConfig_Template.fields tmpl))  
      
  |> VEliteForm.with_ok_button ~ok:(AdLib.get `Event_Edit_Submit) 

let () = define UrlClient.Events.def_edit begin fun parents entity access -> 
  
  let! save = O.Box.react Fmt.Unit.fmt begin fun () json _ res -> 
    return res
  end in 
  
  O.Box.fill begin 

    let! data = ohm begin
      let! t = ohm_req_or (return []) $ O.decay (MEntity.Data.get (MEntity.Get.id entity)) in
      return $ MEntity.Data.data t
    end in
      
    let template = template (MEntity.Get.template entity) in
    let form = OhmForm.create ~template ~source:(OhmForm.from_seed (entity,data)) in
    let url  = OhmBox.reaction_endpoint save () in
        
    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ] 
      method here = parents # edit # title
      method body = Asset_EliteForm_Form.render (OhmForm.render form url)
    end)

  end

end
