(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

type edit = <
  title : string ;
  body  : MRich.OrText.t ;
>

let template () = 

  let inner = 
    OhmForm.begin_object (fun ~title ~body -> (object
      method title   = title
      method body    = `Rich (MRich.parse body) 
    end))

    |> OhmForm.append (fun f title -> return $ f ~title) 
	(VEliteForm.text
	   ~left:true
	   ~label:(AdLib.get `Newsletter_Field_Title)
	   (function 
	   | None -> return ""
	   | Some nl -> return (MNewsletter.Get.title nl)) 
	   (OhmForm.required (AdLib.get `Newsletter_Field_Required)))
	
    |> OhmForm.append (fun f body -> return $ f ~body) 
	(VEliteForm.rich     
	   ~label:(AdLib.get `Newsletter_Field_Body)
	   (function 
	   | None -> return ""
	   | Some nl -> return (Html.to_html_string
				  (MRich.OrText.to_html 
				     (MNewsletter.Get.body nl))))
	   (OhmForm.required (AdLib.get `Newsletter_Field_Required)))
	
  in

  let html = Asset_Newsletter_Edit.render () in

  OhmForm.wrap "" html inner

