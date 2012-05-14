(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let login_template = 
  OhmForm.begin_object 
    (fun ~login ~password -> (object
      method login    = login
      method password = password
    end)) 

  |> OhmForm.append (fun f login -> return $ f ~login) 
      (OhmForm.Skin.text 
	 ~label:(AdLib.get `Login_Form_Login) 
	 (fun () -> return "") OhmForm.keep)
      
  |> OhmForm.append (fun f password -> return $ f ~password) 
      (OhmForm.Skin.password
	 ~label:(AdLib.get `Login_Form_Password)
	 OhmForm.keep)

  |> OhmForm.Skin.with_ok_button ~ok:(AdLib.get `Login_Form_Submit)

let () = UrlLogin.def_login begin fun req res -> 

  let  form = OhmForm.create ~template:login_template ~source:OhmForm.empty in

  CPageLayout.core `Login_Title (OhmForm.render form "url") res

end
    
