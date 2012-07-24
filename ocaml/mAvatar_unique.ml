(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Common = MAvatar_common

(* This view and recovery function serves for backwards compatibility ------------------------------------ *)

module RelationView = CouchDB.MapView(struct
  module Key    = Fmt.Make(struct type json t = (IInstance.t * IUser.t) end)
  module Value  = Fmt.Unit
  module Design = Common.Design
  let name = "relation"
  let map  = "if (doc.t == 'avtr') emit([doc.ins,doc.who])"
end)

let find iid uid = 
  let! list = ohm $ RelationView.by_key (iid,uid) in
  match list with 
    | item :: _ -> return $ Some (IAvatar.of_id (item # id))
    | []        -> return None 

(* Based on OhmCouchUnique ----------------------------------------------------------------------------- *)

module MyUniqueDB = CouchDB.Convenience.Database(struct let db = O.db "avatar-u" end)
module MyUnique = OhmCouchUnique.Make(MyUniqueDB)

let key iid uid = OhmCouchUnique.pair (IInstance.to_id iid) (IUser.to_id uid) 
  
let get_if_exists iid uid =
  let iid = IInstance.decay iid and uid = IUser.decay uid in 
  let! aid = ohm $ MyUnique.get_if_exists (key iid uid) in
  match aid with 
    | Some aid -> return $ Some (IAvatar.of_id aid) 
    | None     -> find iid uid 

let get iid uid = 
  let iid = IInstance.decay iid and uid = IUser.decay uid in 
  let key = key iid uid in 
  let! aid = ohm $ MyUnique.get_if_exists key in
  match aid with 
    | Some aid -> return $ IAvatar.of_id aid
    | None     -> let! aid = ohm $ find iid uid in 
		  match aid with 
		    | Some aid -> let! _ = ohm $ MyUnique.lock key (IAvatar.to_id aid) in
				  return aid 
		    | None     -> let! aid = ohm $ MyUnique.get key in
				  return $ IAvatar.of_id aid

 
