(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CEvents_admin_common

module PublishFmt = Fmt.Make(struct
  type json t = [ `Private | `Normal | `Public ]
end)

let template draft = 

  let inner = 
    OhmForm.begin_object (fun ~name ~publish ~date ~address ~page -> (object
      method name    = name
      method publish = publish
      method date    = date
      method address = address
      method page    = page 
    end))
      
    |> OhmForm.append (fun f name -> return $ f ~name) 
	(VEliteForm.text
	   ~label:(AdLib.get `Event_Edit_Name)
	   (fun (event,_) -> return $ BatOption.default "" (MEvent.Get.name event))
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
	   (fun (event,_) -> return $ Some (MEvent.Get.vision event))
	   OhmForm.keep)
	
    |> OhmForm.append (fun f date -> return $ f ~date) 
	(VEliteForm.date 
	   ~label:(AdLib.get `Event_Edit_Date)
	   (fun (event,_) -> return (BatOption.default "" 
				       (BatOption.map Date.to_compact (MEvent.Get.date event))))
	   (OhmForm.keep))
	
    |> OhmForm.append (fun f address -> return $ f ~address) 
	(VEliteForm.text 
	   ~label:(AdLib.get `Event_Edit_Address)
	   (fun (_,data) -> return (BatOption.default "" (MEvent.Data.address data)))
	   (OhmForm.keep))
	
    |> OhmForm.append (fun f page -> return $ f ~page) 
	(VEliteForm.rich     
	   ~label:(AdLib.get `Event_Edit_Page)
	   (fun (_,data) -> return (Html.to_html_string (MRich.OrText.to_html (MEvent.Data.page data))))
	   (OhmForm.keep))
	
  in

  let html = 
    match draft with
      | Some draft -> Asset_Event_EditDraft.render draft
      | None       -> Asset_Event_EditPublished.render ()
  in

  OhmForm.wrap "" html inner

let () = define UrlClient.Events.def_edit begin fun parents event access -> 
  
  let! save = O.Box.react Fmt.Bool.fmt begin fun publish json _ res -> 
    
    let  template = template None in
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
      | str -> Some str
    in

    let address = match BatString.strip result # address with
      | "" -> None
      | str -> Some str
    in

    let date = Date.of_compact (result # date) in 
    
    let page = `Rich (MRich.parse (result # page)) in

    let vision = BatOption.default `Normal (result # publish) in

    let! () = ohm $ MEvent.Set.info
      event (access # self) ~draft:(not publish) ~name ~date ~page ~vision ~address
    in

    (* Redirect to main page *)

    let url = 
      if MEvent.Get.draft event && publish then parents # people # url
      else parents # home # url 
    in 

    return $ Action.javascript (Js.redirect url ()) res

  end in   
  
  O.Box.fill begin 

    let wrap body = 
      Asset_Admin_Page.render (object
	method parents = [ parents # home ; parents # admin ] 
	method here = parents # edit # title
	method body = body
      end)
    in

    let fail = 
      (* TODO : fill in this error page *)
      Asset_Admin_Error.render () 
    in

    let! data = ohm_req_or (wrap fail) $ MEvent.Get.data event in 
      
    let draft =
      if MEvent.Get.draft event then 
	Some (object
	  method draft   = JsCode.Endpoint.to_json (OhmBox.reaction_endpoint save false)
	  method publish = JsCode.Endpoint.to_json (OhmBox.reaction_endpoint save true)
	end)
      else
	None
    in

    let template = template draft in
    let form = OhmForm.create ~template ~source:(OhmForm.from_seed (event,data)) in
    let url  = OhmBox.reaction_endpoint save true in
        
    wrap (Asset_EliteForm_Form.render (OhmForm.render form url))

  end

end
