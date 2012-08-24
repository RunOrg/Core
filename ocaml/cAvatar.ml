(* © 2012 RunOrg *)

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

let name aid = 
  
  let! details = ohm $ MAvatar.details aid in 
  let! name = ohm begin match details # name with 
    | None -> AdLib.get `Anonymous
    | Some name -> return name
  end in 

  return name 

let mini_profile aid = 
  
  let! details = ohm $ MAvatar.details aid in 
  
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

let directory ?url aids = 
  
  let! list = ohm $ Run.list_filter begin fun aid -> 

    let! details = ohm $ MAvatar.details aid in 
    let! name = req_or (return None) (details # name) in
    let! pic = ohm $ CPicture.small_opt (details # picture) in
    let! iid = req_or (return None) (details # ins) in

    let! instance = ohm_req_or (return None) $ MInstance.get iid in 

    let sort = match details # sort with 
      | None | Some "" -> '?', "" 
      | Some str -> match str.[0] with 
	  | 'A' .. 'Z' -> str.[0], str
	  | _          -> '?', str 
    in

    let gender = None in

    let url = match url with 
      | None -> Action.url UrlClient.Profile.home (instance # key) [IAvatar.to_string aid]
      | Some url -> url aid
    in 

    return $ Some (sort, (object
      method url    = url 
      method pic    = pic
      method name   = name
      method status = match details # status with 
	| Some `Admin   -> `Admin gender
	| Some `Token   -> `Member gender
	| Some `Contact 
	| None          -> `Visitor gender
    end))

  end aids in 
  
  let list = List.sort (fun a b -> compare (fst a) (fst b)) list in
  let list = List.map (fun ((c,_),i) -> (c,i)) list in 
  let list = ListAssoc.group_stable list in
  
  let letters = List.map (fun (letter, avatars) -> (object
    method letter = String.make 1 letter
    method people = avatars
  end)) list in

  Asset_Avatar_Directory.render (object
    method letters = letters
  end)
