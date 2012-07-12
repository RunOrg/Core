(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CWebsite_admin_common

let template : (O.BoxCtx.t,'a,'b) OhmForm.template = 

  OhmForm.begin_object (fun ~title ~text -> (object
    method title = title
    method text  = text
  end))
    
  |> OhmForm.append (fun f title -> return $ f ~title) 
      (VEliteForm.text     
	 ~label:(AdLib.get `Website_Admin_Article_Title)
	 (fun p -> return $ p # title)
	 OhmForm.keep)

  |> OhmForm.append (fun f text -> return $ f ~text)
      (VEliteForm.rich     
	 ~label:(AdLib.get `Website_Admin_Article_Text)
	 (fun p -> return $ p # html)
	 OhmForm.keep)
      
  |> VEliteForm.with_ok_button ~ok:(AdLib.get `Website_Admin_Article_Submit) 

let _ = CClient.define_admin UrlClient.Website.def_write begin fun access -> 

  let! save = O.Box.react Fmt.Unit.fmt begin fun () json _ res -> 

    let  src  = OhmForm.from_post_json json in 
    let  form = OhmForm.create ~template ~source:src in
        
    (* Extract the result for the form *)
    
    let fail errors = 
      let  form = OhmForm.set_errors errors form in
      let! json = ohm $ OhmForm.response form in
      return $ Action.json json res
    in
    
    let! result = ohm_ok_or fail $ OhmForm.result form in  
    let  title = result # title in 
    let  html  = MRich.parse (result # text) in
    
    let! bid = ohm $ O.decay 
      (MBroadcast.post (access # iid) (access # self) (`Post (object
	method title = title
	method body  = `Rich html
      end)))
    in

    (* Return to main page *) 

    let url = Action.url UrlClient.article (access # instance # key) (bid,None) in
    return $ Action.javascript (Js.redirect url ()) res

  end in

  O.Box.fill begin

    let form = OhmForm.create ~template ~source:(OhmForm.empty) in
    let url  = OhmBox.reaction_endpoint save () in

    wrap access `Website_Admin_Article_New
      (Asset_EliteForm_Form.render (OhmForm.render form url))

  end 

end 

let _ = CClient.define_admin UrlClient.Website.def_rewrite begin fun access -> 

  let empty = O.Box.fill (return ignore) in

  let! bid = O.Box.parse IBroadcast.seg in 

  let! broadcast = ohm_req_or empty $ O.decay (MBroadcast.get bid) in

  let! save = O.Box.react Fmt.Unit.fmt begin fun () json _ res -> 

    let  src  = OhmForm.from_post_json json in 
    let  form = OhmForm.create ~template ~source:src in
        
    (* Extract the result for the form *)
    
    let fail errors = 
      let  form = OhmForm.set_errors errors form in
      let! json = ohm $ OhmForm.response form in
      return $ Action.json json res
    in
    
    let! result = ohm_ok_or fail $ OhmForm.result form in  
    let  title = result # title in 
    let  html  = MRich.parse (result # text) in
    
    let! ()= ohm $ O.decay 
      (MBroadcast.edit (access # iid) (access # self) bid (`Post (object
	method title = title
	method body  = `Rich html
      end)))
    in

    (* Return to main page *) 

    let url = Action.url UrlClient.article (access # instance # key) (bid,None) in
    return $ Action.javascript (Js.redirect url ()) res

  end in

  O.Box.fill begin

    let title, html = match broadcast # content with 
      | `Post p -> let title = p # title in 
		   let html  = MRich.OrText.to_html p # body in 
		   title, Html.to_html_string html
      | `RSS  r -> let title = r # title in
		   let html  = OhmSanitizeHtml.html r # body in 
		   title, html
    in

    let form = OhmForm.create ~template ~source:(OhmForm.from_seed (object
      method title = title
      method html  = html
    end)) in

    let url  = OhmBox.reaction_endpoint save () in

    wrap access `Website_Admin_Article_Edit
      (Asset_EliteForm_Form.render (OhmForm.render form url))

  end 

end 
