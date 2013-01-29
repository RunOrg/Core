(* © 2013 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

module Data = Fmt.Make(struct
  type json t = <
    t : MType.t ;
    avatarSets "g" : (!string, IAvatarSet.t) ListAssoc.t ;
    groups     "e" : (!string, IGroup.t) ListAssoc.t
  >
end)

module MyDB = MModel.MainDB
module Design = struct
  module Database = MyDB
  let name = "preconfig_namer"
end

module Tbl = CouchDB.Table(MyDB)(IInstance)(Data)

type t = IInstance.t

let load id = IInstance.decay id

let default = object
  method t = `PreConfigNamer
  method groups     = []
  method avatarSets = []
end

let get iid = 
  let! data = ohm $ Tbl.get iid in
  return $ BatOption.default default data

(* Reverse compatibility with silly old name for the all-members group name.
   NEVER let a non-techie name things... again. *)
let rec find list name = 
  match ListAssoc.try_get list name with 
    | Some id -> Some id 
    | None -> if name = "members" then find list "entity.sample.group-simple.allmembers.name" else None

let avatarSet name iid = 

  let update iid = 
    let! data = ohm $ get iid in
    match find (data # avatarSets) name with 
      | Some id -> return (id, `keep)
      | None -> let id = IAvatarSet.gen () in 
		let data = object
		  method t          = data # t
		  method avatarSets = (name,id) :: (data # avatarSets)
		  method groups     = data # groups
		end in 
		return (id, `put data)
  in

  Tbl.Raw.transaction iid update

let group name iid = 

  let update iid = 
    let! data = ohm $ get iid in
    match find (data # groups) name with 
      | Some id -> return (id, `keep )
      | None    -> let id = IGroup.gen () in 
		   let data = object
		     method t          = data # t
		     method avatarSets = data # avatarSets
		     method groups     = (name,id) :: (data # groups)
		   end in 
		   return (id, `put data)
  in

  Tbl.Raw.transaction iid update

let set_admin iid gid asid = 

  let update iid = 
    let! data = ohm $ get iid in
    
    let data = object
      method t = data # t
      method avatarSets = ListAssoc.replace IGroup.admin asid  (data # avatarSets)
      method groups     = ListAssoc.replace IGroup.admin gid   (data # groups)
    end in 

    return ((), `put data)
  in

  Tbl.Raw.transaction iid update
    

