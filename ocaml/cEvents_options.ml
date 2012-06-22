(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module AccessFmt = Fmt.Make(struct
  type json t = [ `Admin | `Member ]
end)

let template = 

  (VEliteForm.radio     
     ~label:(AdLib.get `Events_Options_CanCreate)
     ~detail:(AdLib.get `Events_Options_CanCreate_Detail)
     ~format:AccessFmt.fmt
     ~source:[ `Admin,  (AdLib.write `Events_Options_Admin) ;
	       `Member, (AdLib.write `Events_Options_Member) ]
     (fun iid -> let! access = ohm $ MInstanceAccess.create_event iid in
		 return (Some access))
     OhmForm.keep)
      
  |> VEliteForm.with_ok_button ~ok:(AdLib.get `Events_Options_Submit) 

let () = CClient.define UrlClient.Events.def_options begin fun access -> 
  O.Box.fill $ O.decay begin

    let form = OhmForm.create ~template ~source:(OhmForm.from_seed (access # iid)) in
    let url  = JsCode.Endpoint.of_url "" in

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
