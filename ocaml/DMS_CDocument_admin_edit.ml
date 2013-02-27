(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open DMS_CDocument_common 
open DMS_CDocument_admin_common

let template () = 

  let inner = 
    OhmForm.begin_object (fun ~name -> (object
      method name   = name
    end))
      
    |> OhmForm.append (fun f name -> return $ f ~name) 
	(VEliteForm.text
	   ~label:(AdLib.get `DMS_Document_Edit_Name)
	   (fun doc -> return (MDocument.Get.name doc)) 
	   (OhmForm.required (AdLib.get `DMS_Document_Edit_Required)))
	
  in

  let html = Asset_DMS_DocumentEdit.render () in
  OhmForm.wrap "" html inner

let () = define Url.Doc.def_edit begin fun parents rid doc access ->
  
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

    let name = BatString.strip result # name in

    let! () = ohm $ MDocument.Set.name name doc (access # actor) in

    (* Redirect to main page *)

    let url = parents # home # url in 
    return $ Action.javascript (Js.redirect url ()) res

  end in   
  
  O.Box.fill begin 
      
    let template = template () in
    let form = OhmForm.create ~template ~source:(OhmForm.from_seed doc) in
    let url  = OhmBox.reaction_endpoint save () in
        
    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ] 
      method here = parents # edit # title
      method body = Asset_EliteForm_Form.render (OhmForm.render form url)
    end)

  end

end 
