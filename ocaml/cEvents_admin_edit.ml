(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CEvents_admin_common

module PublishFmt = Fmt.Make(struct
  type json t = [ `Website | `Member | `Secret ]
end)

let template : (O.BoxCtx.t,'a,'b) OhmForm.template = 

  OhmForm.begin_object (fun ~name ~publish -> (object
    method name = name
    method publish = publish
  end))
    
  |> OhmForm.append (fun f name -> return $ f ~name) 
      (VEliteForm.text
	 ~label:(AdLib.get `Event_Edit_Name)
	 (fun () -> return "")
	 (OhmForm.required (AdLib.get `Event_Edit_Required)))

  |> OhmForm.append (fun f publish -> return $ f ~publish) 
      (VEliteForm.radio     
	 ~label:(AdLib.get `Event_Edit_Publish)
	 ~detail:(AdLib.get `Event_Edit_Publish_Detail)
	 ~format:PublishFmt.fmt
	 ~source:[ `Website,  (AdLib.write `Event_Edit_Publish_Website) ;
		   `Member, (AdLib.write `Event_Edit_Publish_Member) ; 
		   `Secret, (AdLib.write `Event_Edit_Publish_Secret) ]
	 (fun () -> return $ Some `Member)
	 OhmForm.keep)
      
  |> VEliteForm.with_ok_button ~ok:(AdLib.get `Event_Edit_Submit) 

let () = define UrlClient.Events.def_edit begin fun parents entity access -> 
  
  let! save = O.Box.react Fmt.Unit.fmt begin fun () json _ res -> 
    return res
  end in 

  let form = OhmForm.create ~template ~source:(OhmForm.from_seed ()) in
  let url  = OhmBox.reaction_endpoint save () in
  
  O.Box.fill begin 
    
    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ] 
      method here = parents # edit # title
      method body = Asset_EliteForm_Form.render (OhmForm.render form url)
    end)

  end

end
