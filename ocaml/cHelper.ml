(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

(* Creates a new contact from the provided information, returns the corresponding avatar.
   If the e-mail is already known, reuses existing contact. *)

let create_avatar
    ~firstname ~lastname ~email
    ?picture ?birthdate ?address ?city ?zipcode ?country ?phone ?cellphone ?gender
    inst = 

  let general = MProfile.Data.({
    firstname ;
    lastname ;
    email ;
    birthdate ;
    phone ;
    cellphone ;
    address ;
    zipcode ;
    city ;
    country ;
    picture ;
    gender ;
  }) in 
  
  let! user = ohm 
    (MProfile.create inst general |> Run.map (function `ok (user,_) | `exists user -> user))
  in
  
  MAvatar.become_contact inst user  
    
(* Assigns a contact to an entity. If the entity's group contains any fields, only
   assign the contact if [force] is set. Uses the provided [action] or, if missing, 
   computes it based on the entity configuration.
*)

let add_avatar_to_entity ctx ?(force=false) ~actions avatar eid = 

  let! entity = ohm_req_or (return None) (MEntity.try_get ctx eid) in
  let! entity = ohm_req_or (return None) (MEntity.Can.view entity) in 

  let  gid    = MEntity.Get.group entity in
  let! group  = ohm_req_or (return None) (MGroup.try_get ctx gid) in
  let! group  = ohm_req_or (return None) (MGroup.Can.write group) in

  if MGroup.Fields.get group = [] || force then begin 

    let! from = ohm (ctx # self) in    
    let! () = ohm $ MMembership.admin ~from (MGroup.Get.id group) avatar actions in 
    return (Some true)

  end else return (Some false)

  
let assign_avatar_to_entity ctx ?(force=false) ?action avatar eid = 

  let! entity = ohm_req_or (return None) (MEntity.try_get ctx eid) in
  let! entity = ohm_req_or (return None) (MEntity.Can.view entity) in 

  let actions = match BatOption.default (MEntity.Get.on_add entity) action with
    | `ignore -> []
    | `invite -> [ `Invite ; `Accept true ] 
    | `add    -> [ `Accept true ; `Default true ]
  in

  add_avatar_to_entity ctx ~force ~actions avatar eid

