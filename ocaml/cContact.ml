(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let () = UrlSplash.def_contact begin fun req res -> 

  let data = match req # post with 
    | None 
    | Some (`JSON _) -> BatMap.empty 
    | Some (`POST m) -> m
  in

  let data = match req # cookie "mailing" with 
    | None -> data
    | Some mailing -> BatMap.add "mailing" mailing data in

  let redirect = try Some (BatMap.find "redirect" data) with Not_found -> None in
  let data = BatMap.remove "redirect" data in 

  let uids = try [ IUser.of_string (BatMap.find "to" data) ] with Not_found -> MAdmin.list () in
  let data = BatMap.remove "to" data in 

  let write html = BatMap.iter begin fun k v -> 
    Html.concat [ Html.str "<dt>" ;
		  Html.esc k ;
		  Html.str "</dt><dd>" ;
		  Html.esc v ; 
		  Html.str "</dt>" ] html
  end data in 
  
  let body = Html.concat [ Html.str "<dl>" ; write ; Html.str "</dl>" ] in

  let! () = ohm $ Run.list_iter begin fun uid -> 

    let! _ = ohm $ MMail.Send.send uid begin fun uid user send -> 

      send 
	~owid:(user # white) 
	~subject:"Demande de contact"
	~html:body
	()
	
    end in

    return ()

  end uids in

  match redirect with 
  | None -> return res
  | Some url -> return (Action.redirect url res)

end
