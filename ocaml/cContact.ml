(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let () = UrlSplash.def_contact begin fun req res -> 

  let data = match req # post with 
    | None 
    | Some (`JSON _) -> BatPMap.empty 
    | Some (`POST m) -> m
  in

  let write html = BatPMap.iter begin fun k v -> 
    Html.concat [ Html.str "<dt>" ;
		  Html.esc k ;
		  Html.str "</dt><dd>" ;
		  Html.esc v ; 
		  Html.str "</dt>" ] html
  end data in 
  
  let body = Html.concat [ Html.str "<dl>" ; write ; Html.str "</dl>" ] in

  let! () = ohm $ Run.list_iter begin fun uid -> 

    let! _ = ohm $ MMail.send_to_self uid begin fun uid user send -> 

      send 
	~owid:(user # white) 
	~subject:(return "Demande de contact")
	~html:(return body) 

    end in

    return ()

  end (MAdmin.list ()) in

  return res

end
