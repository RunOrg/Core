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
