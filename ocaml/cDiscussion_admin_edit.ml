(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CDiscussion_admin_common

let template () = 

  let inner = 
    OhmForm.begin_object (fun ~title ~body -> (object
      method title = title
      method body  = body 
    end))
      
    |> OhmForm.append (fun f title -> return $ f ~title) 
	(VEliteForm.text
	   ~label:(AdLib.get `Discussion_Field_Title)
	   (MDiscussion.Get.title |- return)
	   (OhmForm.required (AdLib.get `Discussion_Field_Required)))
	
    |> OhmForm.append (fun f body -> return $ f ~body) 
	(VEliteForm.rich     
	   ~label:(AdLib.get `Discussion_Field_Body)
	   (MDiscussion.Get.body |- MRich.OrText.to_html |- Html.to_html_string |- return) 
	   (OhmForm.keep))
	
  in

  let html = Asset_Discussion_Edit.render () in

  OhmForm.wrap "" html inner

let () = define UrlClient.Discussion.def_edit begin fun parents discn access -> 
  
  let! save = O.Box.react Fmt.Bool.fmt begin fun publish json _ res -> 
    
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

    let title = result # title in
    let body = `Rich (MRich.parse (result # body)) in

    let! () = ohm $ MDiscussion.Set.edit
      discn (access # actor) ~title ~body
    in

    (* Redirect to main page *)

    let url = parents # home # url in 

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

    let template = template () in
    let form = OhmForm.create ~template ~source:(OhmForm.from_seed discn) in
    let url  = OhmBox.reaction_endpoint save true in
        
    wrap (Asset_EliteForm_Form.render (OhmForm.render form url))

  end

end
