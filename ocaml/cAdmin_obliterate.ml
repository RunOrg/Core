(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

let () = CAdmin_common.register UrlAdmin.obliterate begin fun i18n user request response ->

  let select notfound = 

    let title = return (View.esc "Suppression de comptes") in
    
    let error = match notfound with 
      | Some email -> "<code>" ^ email ^ "</code> non trouvé! <br/>"
      | None       -> ""
    in

    let body = 
      return begin 
	View.str ( error 
		   ^ "<form action='' method='GET'>"
		   ^ "<label>Email: <input name='email'/></label>"
		   ^ "<button>Supprimer</button> "
		   ^ "<b>La suppression est définitive, vérifiez avant de cliquer!</b>"
		   ^ "</form>" )
      end
    in

    CCore.render ~title ~body response 
  in
   
  let! email = req_or (select None) (request # post "email") in

  let! uid  = ohm_req_or (select (Some email)) $ MUser.by_email email in 
  let! data = ohm_req_or (select (Some email)) $ MUser.admin_get user uid in
  let! ()   = true_or (select (Some email)) (data # destroyed = None) in 

  let! ()   = ohm $ MUser.Backdoor.obliterate user uid in

  let title = return (View.esc "Suppression de compte") in
  
  let body = 
    return begin 
      View.str "<h1>Compte supprimé!</h1>"
    end
  in
  
  CCore.render ~title ~body response   

end

