(* © 2012 RunOrg *)
open Ohm
open Ohm.Universal
open BatPervasives

let template groups = 

  let inner = 
    OhmForm.begin_object (fun ~groups ~title ~body -> (object
      method groups = groups 
      method title  = title
      method body   = body 
    end))

    |> OhmForm.append (fun f groups -> return $ f ~groups) 
	(VEliteForm.picker
	   ~left:true
	   ~label:(AdLib.get `Discussion_Field_To)
	   ~format:IEntity.fmt
	   ~static:groups
	   (fun _ -> return []) 
	   (fun f gids -> return (Ok gids)))
      
    |> OhmForm.append (fun f title -> return $ f ~title) 
	(VEliteForm.text
	   ~left:true
	   ~label:(AdLib.get `Discussion_Field_Title)
	   (fun _ -> return "") 
	   (OhmForm.required (AdLib.get `Discussion_Field_Required)))
	
    |> OhmForm.append (fun f body -> return $ f ~body) 
	(VEliteForm.rich     
	   ~label:(AdLib.get `Discussion_Field_Body)
	   (fun _ -> return "")
	   (OhmForm.keep))
	
  in

  let html = Asset_Discussion_Create.render () in

  OhmForm.wrap "" html inner

let () = CClient.define UrlClient.Discussion.def_create begin fun access ->
  
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
    let gids  = result # groups in 
    let title = result # title in
    let body = `Rich (MRich.parse (result # body)) in

    let () = Util.log "%s" (String.concat " " (List.map IEntity.to_string gids)) in

    let! groups = ohm $ Run.list_filter begin fun gid -> 
      let! group = ohm_req_or (return None) $ O.decay (MEntity.try_get (access # actor) gid) in 
      let! group = ohm_req_or (return None) $ O.decay (MEntity.Can.view group) in
      return $ Some (MEntity.Get.group group)
    end gids in 

    let! () = true_or (return res) (groups <> []) in

    let! did = ohm $ MDiscussion.create (access # actor) ~title ~body ~groups in

    (* Redirect to main page *)

    let  url = Action.url UrlClient.Discussion.see (access # instance # key) [ IDiscussion.to_string did ] in

    return $ Action.javascript (Js.redirect url ()) res

  end in   
  
  O.Box.fill $ O.decay begin 

    let wrap body = 
      Asset_Admin_Page.render (object
	method parents = [] 
	method here = AdLib.get `Discussion_Create_Title
	method body = body
      end)
    in

    let! list = ohm $ MEntity.All.get_by_kind (access # actor) `Group in
    let! groups = ohm $ Run.list_map (fun group -> 
      let! name = ohm $ CEntityUtil.name group in 
      let  eid  = IEntity.decay (MEntity.Get.id group) in
      return (eid, name, return (Html.esc name)) 
    ) list in 

    let template = template groups in
    let form = OhmForm.create ~template ~source:(OhmForm.empty) in
    let url  = OhmBox.reaction_endpoint save () in
        
    wrap (Asset_EliteForm_Form.render (OhmForm.render form url))

  end

end

