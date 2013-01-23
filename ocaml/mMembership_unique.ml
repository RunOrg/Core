(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal

module UniqueDB = CouchDB.Convenience.Database(struct let db = O.db "membership-u" end)
module Unique = OhmCouchUnique.Make(UniqueDB)

let key group avatar = 
  OhmCouchUnique.pair
    (IAvatarSet.to_id (IAvatarSet.decay group))
    (IAvatar.to_id (IAvatar.decay avatar)) 

let find group avatar = 
  let! id = ohm $ Unique.get (key group avatar) in
  return $ IMembership.of_id id

let find_if_exists group avatar = 
  let! id = ohm $ Unique.get_if_exists (key group avatar) in
  return $ BatOption.map IMembership.of_id id

let obliterate gid aid = 
  Unique.remove (key gid aid) 
