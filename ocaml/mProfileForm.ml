(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Info  = MProfileForm_info 
module Store = MProfileForm_store
module Table = CouchDB.ReadTable(Store.DataDB)(IProfileForm)(Store.Raw)
module All   = MProfileForm_all 
module Data  = MProfileForm_data

type data = Data.data 

let create access aid ~kind ~hidden ~name ~data = 

  let! now = ohmctx (#time) in

  let pfid = IProfileForm.gen () in

  let init = Info.({
    iid     = IInstance.decay (IIsIn.instance (access # isin)) ;
    aid     ;
    name    ;
    kind    ;
    hidden  ;
    created = (now, IAvatar.decay access # self) ;
    updated = None
  }) in

  let who  = `user (Id.gen (), IAvatar.decay (access # self)) in
  let info = MUpdateInfo.info ~who in

  let! _ = ohm $ Store.create ~id:pfid ~info ~init ~diffs:[] () in
  let! _ = ohm $ Data.set pfid info data in

  return pfid
     
let update pfid ?hidden ?name ?(data=[]) access = 
  
  let who = `user (Id.gen (), IAvatar.decay (access # self)) in
  let info = MUpdateInfo.info ~who in

  let diffs = BatList.filter_map identity 
    [ BatOption.map (fun hidden -> `Hiding hidden) hidden ;
      BatOption.map (fun name -> `Name name) name ;
      Some (`Author (IAvatar.decay (access # self))) ]
  in
    
  let! () = ohm begin 
    if hidden <> None || name <> None || data <> [] then
      let! _ = ohm $ Store.update ~id:(IProfileForm.decay pfid) ~diffs ~info () in
      if data <> [] then Data.set pfid info data else return () 
    else
      return () 
  end in

  return () 

let get pfid = 
  let! data = ohm_req_or (return None) $ Table.get (IProfileForm.decay pfid) in
  return $ Some (data # current) 

let get_data pfid = 
  Data.get pfid 

let as_admin pfid _ = 
  (* Administrator can edit profile forms *)
  IProfileForm.Assert.edit pfid

let as_myself pfid access = 
  let! info = ohm_req_or (return None) $ get pfid in 
  if not info.Info.hidden && info.Info.aid = IAvatar.decay (access # self) then
    (* I can view this non-hidden form about my profile *)
    return $ Some (IProfileForm.Assert.view pfid) 
  else
    return None

let access pfid access = 
  match IIsIn.Deduce.is_admin (access # isin) with 
    | Some _ -> return $ `Edit (as_admin pfid ())
    | None   -> let! pfid = ohm_req_or (return `None) $ as_myself pfid access in 
		return $ `View pfid

