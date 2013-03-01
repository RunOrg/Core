(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open DMS_CDocument_common 
open DMS_CDocument_admin_common

(* Render an individual metafield *)
let show_metafield ~fieldkey ~fieldinfo = 

  let label = AdLib.get (fieldinfo # label) in

  let seed (_,data) = try BatPMap.find fieldkey data with Not_found -> Json.Null in

  (* String fields *)

  let seed_string s = 
    match seed s with 
      | Json.String s -> return s
      | _ -> return ""
  in

  let parse_string _ s = 
    let s = BatString.trim s in
    if s = "" then return (Ok Json.Null) else return (Ok (Json.String s))
  in

  (* Date fields *)

  let seed_date s = 
    match Date.of_json_safe (seed s) with 
      | Some d -> return (Date.to_iso8601 d)
      | None -> return ""
  in
  
  let parse_date _ s = 
    match Date.of_iso8601 s with 
      | Some d -> return (Ok (Date.to_json d))
      | None -> return (Ok (Json.Null))
  in

  (* Pickers *)

  let format = Fmt.String.fmt in

  let source list = 
    List.map (fun (k,v) -> k, AdLib.write v) list
  in

  let seed_pickone s = 
    match try Json.to_list (Json.to_string) (seed s) with _ -> [] with
      | h :: _ -> return (Some h)
      | [] -> return None
  in

  let seed_pickmany s = 
    return (try Json.to_list (Json.to_string) (seed s) with _ -> [])
  in

  let parse_pickone _ = function
    | Some s -> return (Ok (Json.String s))
    | None -> return (Ok Json.Null)
  in

  let parse_pickmany _ l = 
    return (Ok (Json.of_list Json.of_string l))
  in

  match fieldinfo # kind with 
    | `Date       -> VEliteForm.date ~label seed_date parse_date
    | `TextShort  -> VEliteForm.text ~label seed_string parse_string
    | `TextLong   -> VEliteForm.textarea ~label seed_string parse_string
    | `PickOne  l -> VEliteForm.radio ~label ~format ~source:(source l) seed_pickone parse_pickone
    | `PickMany l -> VEliteForm.checkboxes ~label ~format ~source:(source l) seed_pickmany parse_pickmany

let template metafields = 

  let inner = 
    OhmForm.begin_object (fun ~name ~meta -> (object
      method name   = name
      method meta   = meta 
    end))
      
    |> OhmForm.append (fun f name -> return $ f ~name) 
	(VEliteForm.text
	   ~label:(AdLib.get `DMS_Document_Edit_Name)
	   (fun (doc,_) -> return (MDocument.Get.name doc)) 
	   (OhmForm.required (AdLib.get `DMS_Document_Edit_Required)))
	
    |> OhmForm.append (fun f meta -> return $ f ~meta) begin

      (* Traverse all the possible fields... *)
      List.fold_left begin fun form (fieldkey, fieldinfo) -> 

	(* For each field, append the result to the complete meta-map *)
	OhmForm.append (fun map json -> return (BatPMap.add fieldkey json map)) 
	  (show_metafield ~fieldkey ~fieldinfo) form

      end (OhmForm.begin_object BatPMap.empty) metafields
      
    end

  in

  let html = Asset_DMS_DocumentEdit.render () in
  OhmForm.wrap "" html inner

let () = define Url.Doc.def_edit begin fun parents rid doc access ->
  
  let! metafields = ohm $ MDocMeta.fields (access # iid) in

  let! meta = ohm $ MDocMeta.get (MDocument.Get.id doc) in

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

    let data = result # meta in
    let! () = ohm $ MDocMeta.Set.data data meta (access # actor) in 

    (* Redirect to main page *)

    let url = parents # home # url in 
    return $ Action.javascript (Js.redirect url ()) res

  end in   
  
  O.Box.fill begin 
      
    let template = template metafields in
    let form = OhmForm.create ~template 
      ~source:(OhmForm.from_seed (doc,MDocMeta.Get.data meta)) in
    let url  = OhmBox.reaction_endpoint save () in
        
    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ] 
      method here = parents # edit # title
      method body = Asset_EliteForm_Form.render (OhmForm.render form url)
    end)

  end

end 
