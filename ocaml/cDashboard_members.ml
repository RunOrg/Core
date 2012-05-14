(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CDashboard_common

module Contacts  = CDashboard_members_contacts
module Directory = CDashboard_members_directory
module Entities  = CDashboard_entities
module Grants    = CDashboard_grants

let dynamic ~ctx = 
  
  let! contacts_reaction      = ohm $ Contacts.block               ~ctx in
  let! directory_reaction     = ohm $ Directory.block              ~ctx in
  let! grants_reaction        = ohm $ Grants.block                 ~ctx in
  let! groups_reaction        = ohm $ Entities.block `Group        ~ctx in
  let! subscriptions_reaction = ohm $ Entities.block `Subscription ~ctx in

  return (fun callback ->  

    let! contacts      = contacts_reaction in
    let! directory     = directory_reaction in
    let! grants        = grants_reaction in 
    let! groups        = groups_reaction in 
    let! subscriptions = subscriptions_reaction in 
    
    let list = [
      contacts ;
      grants ;
      subscriptions ;
      groups 
    ] in
    
    callback (directory, BatList.filter_map identity list)

  )
