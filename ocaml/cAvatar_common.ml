(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

type mini_profile = <
  url  : string ;
  pic  : string ;
  pico : string option ;
  name : string ;
  nameo : string option 
> ;;

let mini_profile_from_details aid details = 

  let! name = ohm begin match details # name with 
    | None -> AdLib.get `Anonymous
    | Some name -> return name
  end in 
  
  let! pic  = ohm $ CPicture.small (details # picture) in
  let! pico = ohm $ CPicture.small_opt (details # picture) in

  let! url  = ohm begin
    let! iid = req_or (return None) (details # ins) in
    let! instance = ohm_req_or (return None) $ MInstance.get iid in 
    return $ Some (Action.url UrlClient.Profile.home (instance # key) [IAvatar.to_string aid])
  end in 

  let url = BatOption.default "javascript:void(0)" url in 

  return (object
    method url = url
    method pic = pic
    method pico = pico
    method name = name
    method nameo = details # name
  end)

let mini_profile aid = 
  let! details = ohm $ MAvatar.details aid in 
  mini_profile_from_details aid details
