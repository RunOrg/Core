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
	 ~label:(return "Login") 
	 (fun () -> return "") OhmForm.keep)
      
  |> OhmForm.append (fun f password -> return $ f ~password) 
      (OhmForm.Skin.password
	 ~label:(return "Password")
	 OhmForm.keep)

  |> OhmForm.Skin.with_ok_button ~ok:(return "Log In")

let () = UrlLogin.def_login begin fun req res -> 

  let  form = OhmForm.create ~template:login_template ~source:OhmForm.empty in
  let! html = ohm $ OhmForm.render form "url" in
  let! title = ohm $ return "Login" in

  return $ Action.page (Html.print_page ~title html) res

end
    
