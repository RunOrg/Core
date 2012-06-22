(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module AccessFmt = Fmt.Make(struct
  type json t = [ `Admin | `Member ]
end)

let template : (O.BoxCtx.t,'a,'b) OhmForm.template = 

  (VEliteForm.radio     
     ~label:(AdLib.get `Events_Options_CanCreate)
     ~detail:(AdLib.get `Events_Options_CanCreate_Detail)
     ~format:AccessFmt.fmt
     ~source:[ `Admin,  (AdLib.write `Events_Options_Admin) ;
	       `Member, (AdLib.write `Events_Options_Member) ]
     (fun iid -> let! access = ohm $ O.decay (MInstanceAccess.create_event iid) in
		 return (Some access))
     OhmForm.keep)
      
  |> VEliteForm.with_ok_button ~ok:(AdLib.get `Events_Options_Submit) 

let () = CClient.define_admin UrlClient.Events.def_options begin fun access -> 

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
    let events = match result with 
      | None -> `Admin
      | Some `Admin -> `Admin
      | Some `Member -> `Token
    in

    let! () = ohm $ O.decay 
      (MInstanceAccess.update (access # iid)
	 (fun data -> MInstanceAccess.Data.({ data with events })))
    in 
    
    (* Return to main page *) 

    let url = Action.url UrlClient.Events.home (access # instance # key) [] in
    return $ Action.javascript (Js.redirect url ()) res

  end in

  O.Box.fill begin

    let form = OhmForm.create ~template ~source:(OhmForm.from_seed (access # iid)) in
    let url  = OhmBox.reaction_endpoint save () in

    Asset_Admin_Page.render (object
      method parents = [ object
	method title = AdLib.get `Events_Title
	method url   = Action.url UrlClient.Events.home (access # instance # key) []
      end ]
      method here = AdLib.get `Events_Options_Title
      method body = Asset_EliteForm_Form.render (OhmForm.render form url)
    end)
  end
end
