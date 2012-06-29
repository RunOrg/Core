(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

type mini_profile = <
  url  : string ;
  pic  : string ;
  name : string 
>

let mini_profile aid = 
  
  let! details = ohm $ MAvatar.details aid in 
  
  let! name = ohm begin match details # name with 
    | None -> AdLib.get `Anonymous
    | Some name -> return name
  end in 
  
  let! pic = ohm $ CPicture.small (details # picture) in

  return (object
    method url = "javascript:void(0)"
    method pic = pic
    method name = name
  end)

let directory aids = 
  
  let! list = ohm $ Run.list_map begin fun aid -> 

    let! details = ohm $ MAvatar.details aid in 

    let! name = ohm begin match details # name with 
      | None -> AdLib.get `Anonymous
      | Some name -> return name
    end in 

    let! pic = ohm $ CPicture.small_opt (details # picture) in

    let sort = match details # sort with 
      | None | Some "" -> '?', "" 
      | Some str -> match str.[0] with 
	  | 'A' .. 'Z' -> str.[0], str
	  | _          -> '?', str 
    in

    let gender = None in

    return (sort, (object
      method url    = "javascript:void(0)"
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
