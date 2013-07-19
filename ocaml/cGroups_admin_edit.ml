(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CGroups_admin_common

let template () = 

  let inner = 
    OhmForm.begin_object (fun ~name ~vision ~listView -> (object
      method name     = name
      method vision   = vision
      method listView = listView
    end))
      
    |> OhmForm.append (fun f name -> return $ f ~name) 
	(VEliteForm.text
	   ~label:(AdLib.get `Group_Edit_Name)
	   (fun group -> MGroup.Get.fullname group) 
	   (OhmForm.required (AdLib.get `Group_Edit_Required)))
	
    |> OhmForm.append (fun f vision -> return $ f ~vision) 
	(VEliteForm.radio     
	   ~label:(AdLib.get `Group_Edit_Publish)
	   ~detail:(AdLib.get `Group_Edit_Publish_Detail)
	   ~format:MGroup.Vision.fmt
	   ~source:(List.map
		      (fun (stat, tag) -> stat, Asset_Event_StatusRadio.render (object
			method status = tag
			method label  = AdLib.get (`Group_Edit_Publish_Label stat)
		      end))
		      [ `Public,  Some `Website ;
			`Normal,  None ; 
			`Private, Some `Secret ])
	   (fun group -> return $ Some (MGroup.Get.vision group))
	   OhmForm.keep)	

    |> OhmForm.append (fun f listView -> return $ f ~listView) 
	(VEliteForm.radio     
	   ~label:(AdLib.get `Group_Edit_ListView)
	   ~detail:(AdLib.get `Group_Edit_ListView_Detail)
	   ~format:MGroup.ListView.fmt
	   ~source:(List.map 
		      (fun x -> x, Asset_Event_StatusRadio.render (object
			method status = None
			method label = AdLib.get (`Group_Edit_ListView_Label x)
		       end))
		      [ `Viewers ; `Registered ; `Managers ])
	   (fun group -> return $ Some (MGroup.Get.listView group))
	   OhmForm.keep)	

  in

  let html = Asset_Group_Edit.render () in
  OhmForm.wrap "" html inner

let () = define UrlClient.Members.def_edit begin fun parents group access -> 
  
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
      | ""  -> None
      | str -> Some (`text str) 
    in

    let vision = BatOption.default `Normal (result # vision) in
    let listView = BatOption.default `Managers (result # listView) in 

    let! () = ohm $ MGroup.Set.info ~name ~vision ~listView group (access # actor) in

    (* Redirect to main page *)

    let url = parents # home # url in 
    return $ Action.javascript (Js.redirect url ()) res

  end in   
  
  O.Box.fill begin 
      
    let template = template () in
    let form = OhmForm.create ~template ~source:(OhmForm.from_seed group) in
    let url  = OhmBox.reaction_endpoint save () in
        
    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ] 
      method here = parents # edit # title
      method body = Asset_EliteForm_Form.render (OhmForm.render form url)
    end)

  end

end
