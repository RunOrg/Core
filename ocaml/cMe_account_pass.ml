(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CMe_common

module Parents = CMe_account_parents

let template = 

  OhmForm.begin_object
    (fun ~pass ~pass2 -> (object
      method pass  = pass
      method pass2 = pass2
    end))

  |> OhmForm.append (fun f pass -> return $ f ~pass) 
      (OhmForm.Skin.password
	 ~label:(AdLib.get `MeAccount_Pass_Password) 
	 (OhmForm.required (AdLib.get `MeAccount_Pass_Required)))

  |> OhmForm.append (fun f pass2 -> return $ f ~pass2) 
      (OhmForm.Skin.password 
	 ~label:(AdLib.get `MeAccount_Pass_Pass2) 
	 (OhmForm.required (AdLib.get `MeAccount_Pass_Required)))	  
	  
  |> OhmForm.Skin.with_ok_button ~ok:(AdLib.get `MeAccount_Pass_Submit) 

let () = define UrlMe.Account.def_pass begin fun cuid -> 

  O.Box.fill begin
    
    let form = OhmForm.create ~template ~source:(OhmForm.from_seed ()) in
    let url  = "" in

    Asset_Admin_Page.render (object
      method parents = [ Parents.home ; Parents.admin ] 
      method here  = Parents.pass # title
      method body  = Asset_Form_Clean.render (OhmForm.render form url)
    end)

  end
end
