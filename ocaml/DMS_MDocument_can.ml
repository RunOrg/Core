(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module E = DMS_MDocument_core

include HEntity.Can(struct

  type core = E.t
  type 'a id = 'a DMS_IDocument.id

  let deleted e = e.E.repos = []
  let iid     e = e.E.iid

  let admin   e = 
    let! from_repos = ohm $ Run.list_map (fun rid ->
      let! repo = ohm_req_or (return MAvatarStream.nobody) $ DMS_MRepository.get rid in
      DMS_MRepository.Can.admin_access repo
    ) e.E.repos in
    return MAvatarStream.(union (avatars [e.E.creator] :: from_repos)) 

  let view e = 
    let! from_repos = ohm $ Run.list_map (fun rid ->
      let! repo = ohm_req_or (return MAvatarStream.nobody) $ DMS_MRepository.get rid in
      DMS_MRepository.Can.details_access repo
    ) e.E.repos in
    return MAvatarStream.(union (avatars [e.E.creator] :: from_repos)) 
	
  let id_view  id = DMS_IDocument.Assert.view id
  let id_admin id = DMS_IDocument.Assert.admin id 
  let decay    id = DMS_IDocument.decay id 

  let public _ = false

end)

