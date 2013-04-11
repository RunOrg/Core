(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

include CAvatar_common

module Notify = CAvatar_notify

let name aid = 
  
  let! details = ohm $ MAvatar.details aid in 
  let! name = ohm begin match details # name with 
    | None -> AdLib.get `Anonymous
    | Some name -> return name
  end in 

  return name 

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

let () = UrlClient.def_pickAvatars $ CClient.action begin fun access req res ->

  let result list =   
    let! json = ohm $ VEliteForm.Picker.formatResults IAvatar.fmt list in
    return (Action.json json res)
  in

  let! json = req_or (result []) (Action.Convenience.get_json req) in
  let! mode = req_or (result []) (VEliteForm.Picker.QueryFmt.of_json_safe json) in
  
  let  iid  = IInstance.Deduce.token_see_contacts (access # iid) in

  let by_prefix prefix =
    let  count = 10 in
    let! list  = ohm $ MAvatar.search iid prefix count in
    let  render aid details = 
      let! profile = ohm $ mini_profile_from_details aid details in 
      Asset_Avatar_PickerLine.render profile
    in
    result (List.map (fun (aid, _, details) -> (aid, render aid details)) list)
  in

  let by_json aids = 
    let  aids = BatList.filter_map IAvatar.of_json_safe aids in 
    let! list = ohm $ Run.list_map begin fun aid ->
      let! profile = ohm $ mini_profile aid in
      return (aid, Asset_Avatar_PickerLine.render profile)
    end aids in
    result list
  in

  match mode with 
    | `ByJson   aids   -> by_json aids
    | `ByPrefix prefix -> by_prefix prefix
  
end 

module ForAtom = struct

  let render atom = 
    let  aid = IAvatar.of_id (IAtom.to_id (atom # id)) in
    let! details = ohm (mini_profile aid) in 
    Asset_Avatar_PickerLine.render details

  let search key atid = 
    let  aid = IAvatar.of_id (IAtom.to_id atid) in
    Action.url UrlClient.Profile.home key [ IAvatar.to_string aid ]

  let () = CAtom.register ~nature:`Avatar ~render ~search

end
