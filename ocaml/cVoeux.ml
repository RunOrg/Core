(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let _ = O.register O.core "voeux" Action.Args.none begin fun req res -> 

  let respond html = 
    return $ Action.jsonp ?callback:(req # get "callback") (Html.to_json html) res 
  in 

  let! voeux = ohm $ MVoeux.all () in 
  let! html  = ohm $ Asset_Voeux_All.render voeux in 
  
  respond html 
  
end 
