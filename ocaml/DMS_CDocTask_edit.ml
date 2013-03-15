(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open DMS_CDocTask_common

let template process = 

  let fields = PreConfig_Task.DMS.fields process in
  let states = (PreConfig_Task.DMS.states process) # all in

  let inner = 
    OhmForm.begin_object (fun ~state ~assignee ~notified ~data -> (object
      method state    = state
      method assignee = assignee
      method notified = notified
      method data     = data
    end))

    |> OhmForm.append (fun f state -> return $ f ~state)
	(VEliteForm.radio 
	   ~label:(AdLib.get `DMS_DocTask_Edit_State)
	   ~format:Fmt.Json.fmt
	   ~source:(List.map (fun (json, label) -> json, AdLib.write label) states)
	   (fun task -> return $ Some (MDocTask.Get.state task))
	   OhmForm.keep)

    |> OhmForm.append (fun f assignee -> return $ f ~assignee) 
	(VEliteForm.picker
	   ~label:(AdLib.get `DMS_DocTask_Edit_Assigned)
	   ~format:IAvatar.fmt
	   ~static:[]
	   (fun task -> match MDocTask.Get.assignee task with
	     | None -> return []
	     | Some aid -> return [aid]) 
	   (fun f aids -> match aids with 
	     | [] -> return (Ok None)
	     | x :: _ -> return (Ok (Some x))))

    |> OhmForm.append (fun f notified -> return $ f ~notified) 
	(VEliteForm.picker
	   ~label:(AdLib.get `DMS_DocTask_Edit_Notified)
	   ~format:IAvatar.fmt
	   ~static:[]
	   (fun task -> return (MDocTask.Get.notified task))
	   (fun f aids -> return (Ok aids)))
      
    |> OhmForm.append (fun f data -> return $ f ~data) begin

      OhmForm.seed_map MDocTask.Get.data begin

	(* Traverse all the possible fields... *)
	List.fold_left begin fun form (fieldkey, fieldinfo) -> 

	  (* For each field, append the result to the complete meta-map *)
	  OhmForm.append (fun map json -> return (BatPMap.add fieldkey json map)) 
	    (VField.render ~fieldkey ~fieldinfo) form

	end (OhmForm.begin_object BatPMap.empty) fields

      end
	
    end
	
  in

  VEliteForm.with_ok_button 
    ~ok:(AdLib.get `DMS_DocTask_Save)
    inner

let () = CClient.define Url.Task.def_edit begin fun access ->

  let  e404 = O.Box.fill (Asset_Client_PageNotFound.render ()) in

  let  actor = access # actor in 
  let! rid  = O.Box.parse IRepository.seg in
  let! did  = O.Box.parse IDocument.seg in 
  let! dtid = O.Box.parse IDocTask.seg in

  let! doc  = ohm_req_or e404 $ MDocument.view ~actor did in
  let  did  = MDocument.Get.id doc in

  let! task = ohm_req_or e404 $ MDocTask.getFromDocument dtid did in
  let  process = MDocTask.Get.process task in 

  let  home = parent (access # instance # key) rid doc in

  let! save = O.Box.react Fmt.Unit.fmt begin fun _ json _ res -> 
    
    let  template = template process in
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

    let! () = ohm $ MDocTask.Set.info 
      ?state:(result # state) 
      ~assignee:(result # assignee)
      ~notified:(result # notified)
      ~data:(result # data) 
      task actor
    in

    (* Redirect to main page *)

    return $ Action.javascript (Js.redirect (home # url) ()) res

  end in   

  O.Box.fill begin 

    let template = template process in
    let form = OhmForm.create ~template ~source:(OhmForm.from_seed task) in
    let url  = OhmBox.reaction_endpoint save () in

    Asset_Admin_Page.render (object
      method parents = [ home ]
      method here = AdLib.get `DMS_DocTask_Edit
      method body = Asset_EliteForm_Form.render (OhmForm.render form url)
    end)

  end 

end
