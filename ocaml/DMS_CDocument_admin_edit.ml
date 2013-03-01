(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open DMS_CDocument_common 
open DMS_CDocument_admin_common

let template metafields = 

  let inner = 
    OhmForm.begin_object (fun ~name ~meta -> (object
      method name   = name
      method meta   = meta 
    end))
      
    |> OhmForm.append (fun f name -> return $ f ~name) 
	(VEliteForm.text
	   ~label:(AdLib.get `DMS_Document_Edit_Name)
	   (fun doc -> return (MDocument.Get.name doc)) 
	   (OhmForm.required (AdLib.get `DMS_Document_Edit_Required)))
	
    |> OhmForm.append (fun f meta -> return $ f ~meta) begin

      (* Traverse all the possible fields... *)
      List.fold_left begin fun form (fieldkey, fieldinfo) -> 

	(* For each field, append the result to the complete meta-map *)
	OhmForm.append (fun map json -> return (BatPMap.add fieldkey json map)) begin 

	  let label = AdLib.get (fieldinfo # label) in

	  (* Determine what the field should look like dependeing on its kind. *)
	  VEliteForm.text
	    ~label
	    (fun _ -> return "")
	    (fun field string -> return (Ok (Json.String string)))

	end form 

      end (OhmForm.begin_object BatPMap.empty) metafields
      
    end

  in

  let html = Asset_DMS_DocumentEdit.render () in
  OhmForm.wrap "" html inner

let () = define Url.Doc.def_edit begin fun parents rid doc access ->
  
  let! metafields = ohm $ MDocMeta.fields (access # iid) in

  let! save = O.Box.react Fmt.Unit.fmt begin fun _ json _ res -> 
    
    let  template = template metafields in
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
      
    let template = template metafields in
    let form = OhmForm.create ~template ~source:(OhmForm.from_seed doc) in
    let url  = OhmBox.reaction_endpoint save () in
        
    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ] 
      method here = parents # edit # title
      method body = Asset_EliteForm_Form.render (OhmForm.render form url)
    end)

  end

end 
