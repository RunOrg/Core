(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

module E = MEntity_core
module Signals = MEntity_signals

let get_preconfig_diffs diffs_by_version min_version max_version = 
  let allowed_diffs =
    List.filter
      (fun (version,_) -> version > min_version && version <= max_version)
      diffs_by_version
    |> List.map snd
    |> List.concat
  in

  MPreConfig.template_extract allowed_diffs 

let diffs_up_to split_diffs max_version = 

  let diffs = [`Version max_version] in 
  
  if split_diffs # config = [] then diffs
  else `Config (split_diffs # config) :: diffs
  
module VersionView = CouchDB.DocView(struct
  module Key = Fmt.String
  module Value = Fmt.Unit
  module Doc = E.Format
  module Design = E.Design
  let name = "by_version"
  let map = "emit(doc.c.version || '',null);"
end)

let sorted_versions_above tid version = 
  let applicable_versions = MPreConfig.applies_to tid MPreConfig.template_versions in 
  let versions_above = 
    List.filter (fun v -> v # version > version) applicable_versions 
  in
  List.sort (fun a b -> compare a # version b # version) versions_above

let first_unapplied_version = 
  let! list = ohm $ VersionView.doc_query ~limit:1 () in
  match list with [] -> return (None, MPreConfig.last_template_version) | h :: _ -> 
    
    let entity = h # doc in 
    if entity.E.version >= MPreConfig.last_template_version 
    then return (None, MPreConfig.last_template_version)
    else

      let eid = IEntity.of_id (h # id) in 
      let tid = entity.E.template in

      let versions_above = sorted_versions_above tid entity.E.version in 
     
      match versions_above with 
	| []     -> return $ (Some eid, MPreConfig.last_template_version)
	| h :: _ -> return $ (Some eid, h # version) 

let upgrade ?upto eid = 
  let! entity = ohm_req_or (return ()) $ E.Table.get eid in 

  let diffs_by_version = 
    match MVertical.Template.get entity.E.template with 
      | None -> []
      | Some tmpl -> tmpl # diffs
  in
  
  let min_version = entity.E.version in 
  let max_version = BatOption.default MPreConfig.last_template_version upto in
  
  let diffs = get_preconfig_diffs diffs_by_version min_version max_version in 
  
  let eid = IEntity.Assert.bot eid in 
  
  let () = 
    log "Updating entity %s from version `%s` to version `%s` ..."
      (IEntity.to_string eid) (entity.E.version) (max_version)
  in
  
  let! () = ohm $ Signals.on_upgrade_call (eid,diffs) in
  let! () = ohm $
    MEntity_data.upgrade ~id:eid ~fields:(diffs#fields) ~info:(diffs#info) ()
  in
  
  let! _ = ohm (	    
    E.Store.update
      ~id:(IEntity.decay eid)
      ~diffs:(diffs_up_to diffs max_version)
      ~info:(MUpdateInfo.info ~who:`preconfig)
      ()
  ) in
  
  return ()

let process_oldest_version = 

  let! iid_opt, iversion = ohm $ MInstance.first_unapplied_version in 
  let! eid_opt, eversion = ohm $ first_unapplied_version in 
  
  match iid_opt, eid_opt with 
    | None,     None     -> return (Some 10.)
    | Some iid, None     -> let! () = ohm $ MInstance.upgrade iid in 
			    return None
    | None,     Some eid -> let! () = ohm $ upgrade eid in
			    return None
    | Some iid, Some eid ->
      
      let! () = ohm begin 
	if iversion < eversion then MInstance.upgrade ~upto:eversion iid
	else upgrade ~upto:iversion eid
      end in 
      return None
	   

let () = 
  O.async # periodic 15 process_oldest_version
