(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Edit = CNewsletter_edit

let () = CClient.define UrlClient.Newsletter.def_create begin fun access ->
  
  let! save = O.Box.react Fmt.Unit.fmt begin fun _ json _ res -> 
    
    let  template = Edit.template () in
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
    let body  = result # body in

    let! nlid = ohm $ MNewsletter.create (access # actor) ~title ~body in

    (* Redirect to main page *)

    let  url = Action.url UrlClient.Newsletter.see (access # instance # key) [ INewsletter.to_string nlid ] in

    return $ Action.javascript (Js.redirect url ()) res

  end in   
  
  O.Box.fill $ O.decay begin 

    let wrap body = 
      Asset_Admin_Page.render (object
	method parents = [] 
	method here = AdLib.get `Newsletter_Create_Title
	method body = body
      end)
    in

    let template = Edit.template () in
    let form = OhmForm.create ~template ~source:(OhmForm.empty) in
    let url  = OhmBox.reaction_endpoint save () in
        
    wrap (Asset_EliteForm_Form.render (OhmForm.render form url))

  end

end
