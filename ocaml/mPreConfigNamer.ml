(* © 2012 MRunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

module Data = Fmt.Make(struct
  module IGroup = IGroup
  module IEntity = IEntity
  type json t = <
    t : MType.t ;
    groups   "g" : (!string, IGroup.t) ListAssoc.t ;
    entities "e" : (!string, IEntity.t) ListAssoc.t
  >
end)

module MyDB = MModel.MainDB
module Design = struct
  module Database = MyDB
  let name = "preconfig_namer"
end

module MyTable = CouchDB.Table(MyDB)(IInstance)(Data)

type t = IInstance.t

let load id = IInstance.decay id

let default = object
  method t = `PreConfigNamer
  method groups   = []
  method entities = []
end

let get iid = 
  let! data = ohm $ MyTable.get iid in
  return $ BatOption.default default data

(* Reverse compatibility with silly old name for the all-members group name.
   NEVER let a non-techie name things... again. *)
let rec find list name = 
  match ListAssoc.try_get list name with 
    | Some id -> Some id 
    | None -> if name = "members" then find list "entity.sample.group-simple.allmembers.name" else None

let group name iid = 
	  
  let update iid = 
    let! data = ohm $ get iid in
    match find (data # groups) name with 
      | Some id -> return (id, `keep)
      | None -> let id = IGroup.gen () in 
		let data = object
		  method t        = data # t
		  method groups   = (name,id) :: (data # groups)
		  method entities = data # entities
		end in 
		return (id, `put data)
  in

  MyTable.transaction iid update

let entity name iid = 

  let update iid = 
    let! data = ohm $ get iid in
    match find (data # entities) name with 
      | Some id -> return (id, `keep )
      | None    -> let id = IEntity.gen () in 
		   let data = object
		     method t        = data # t
		     method groups   = data # groups
		     method entities = (name,id) :: (data # entities)
		   end in 
		   return (id, `put data)
  in

  MyTable.transaction iid update

let set_admin iid eid gid = 

  let update iid = 
    let! data = ohm $ get iid in
    
    let data = object
      method t = data # t
      method groups   = ListAssoc.replace "admin" gid  (data # groups)
      method entities = ListAssoc.replace "admin" eid  (data # entities)
    end in 

    return ((), `put data)
  in

  MyTable.transaction iid update
    

