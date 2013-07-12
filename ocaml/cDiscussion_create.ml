(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

(* The type system chokes on the optional parameters... *)
let template (picker : ?left:bool -> label:'a -> ?max:int -> 'c) = 

  let inner = 
    OhmForm.begin_object (fun ~targets ~title ~body -> (object
      method targets = targets
      method title   = title
      method body    = body 
    end))

    |> OhmForm.append (fun f targets -> return $ f ~targets) 
	(picker
	   ~left:true
	   ~label:(AdLib.get `Discussion_Field_To)
	   ~max:30
	   (fun _ -> return []) 
	   (fun f targets -> return (Ok targets)))
      
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
    
    let! picker = ohm (CSearch.target_picker ~query:false access) in
    let  template = template picker in
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
    let gids  = BatList.filter_map (function `Group gid -> Some gid | `Avatar _ -> None) (result # targets) in 
    let aids  = BatList.filter_map (function `Avatar aid -> Some aid | `Group _ -> None) (result # targets) in
    let title = result # title in
    let body = `Rich (MRich.parse (result # body)) in

    let! groups = ohm $ Run.list_filter begin fun gid -> 
      let! group = ohm_req_or (return None) $ MGroup.view ~actor:(access # actor) gid in 
      return $ Some (MGroup.Get.group group)
    end gids in 

    let! () = true_or (return res) (groups <> [] || aids <> []) in

    let! did = ohm $ MDiscussion.create (access # actor) ~title ~body ~groups ~avatars:aids in

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

    let! picker = ohm (CSearch.target_picker access) in

    let template = template picker in
    let form = OhmForm.create ~template ~source:(OhmForm.empty) in
    let url  = OhmBox.reaction_endpoint save () in
        
    wrap (Asset_EliteForm_Form.render (OhmForm.render form url))

  end

end

