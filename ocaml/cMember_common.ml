(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

let contact_picker instance iid isin i18n id name = 
  let url = 
    let user = IIsIn.user isin in
    UrlMember.autocomplete # build instance iid user
  in
  VMember.Picker.component
    ~url
    ~id
    ~name
    ~i18n

let grab_selected request = 
  try match request # post "selected" with None -> None | Some value ->
    let json = Json_io.json_of_string value in
    let list = Json_type.Browse.list Json_type.Browse.string json in 
    Some (List.map IAvatar.of_string list)
  with _ -> None

let add_to_group ~self ~avatar ~group ~on_add =
 
  let actions = match on_add with 
    | `ignore -> []
    | `invite -> [ `Invite ; `Accept true ] 
    | `add    -> [ `Accept true ; `Default true ]
  in

  MMembership.admin ~from:self (MGroup.Get.id group) avatar actions 

