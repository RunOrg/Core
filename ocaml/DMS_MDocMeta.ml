(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

(* Field management ----------------------------------------------------------------------------------------- *)

module Field = struct
  type t = string
  let to_string = identity
  let of_string = identity
end

module FieldType = struct
  type t = 
    [ `TextShort
    | `TextLong
    | `AtomOne  of IAtom.Nature.t
    | `AtomMany of IAtom.Nature.t
    | `PickOne  of (string * O.i18n) list
    | `PickMany of (string * O.i18n) list
    | `Date
    ]
end

let instance_field_model = MInstance.Registry.property PreConfig_DMS.Metadata.fmt "dms-metadata"

let fields iid =
  let  iid = IInstance.decay iid in 
  let! model = ohm $ MInstance.Registry.get iid instance_field_model in
  let  model = BatOption.default `Default model in
  return (PreConfig_DMS.metadata model)
  
(* Metadata management -------------------------------------------------------------------------------------- *)

module Data = Fmt.Make(struct
  type t = (Field.t,Json.t) BatPMap.t
  let json_of_t t = 
    Json.Object (BatPMap.foldi (fun k v l -> (k,v) :: l) t [])
  let t_of_json json = 
    List.fold_left (fun m (k,v) -> BatPMap.add k v m) BatPMap.empty 
      (Json.to_assoc json) 
end)

let clean m = 
  BatPMap.filter ((<>) Json.Null) m 

module Cfg = struct

  let name = "dms-docmeta"

  module DataDB = struct
    let database = O.db name
    let host     = "localhost"
    let port     = 5984
  end

  module VersionDB = struct
    let database = O.db (name ^ "-v") 
    let host     = "localhost"
    let port     = 5984
  end

  type ctx = O.ctx
  let couchDB ctx = (ctx : O.ctx :> CouchDB.ctx) 

  module Id = DMS_IDocument
  module Data = Data
  module Diff = Data 

  let apply diff = return begin fun _ _ data ->
    return (clean (BatPMap.foldi BatPMap.add diff data))
  end

  module VersionData = MUpdateInfo
  module ReflectedData = Fmt.Unit
  let reflect _ _ = return () 

end

module Store = OhmCouchVersioned.Make(Cfg)

type 'relation t = {
  id     : 'relation DMS_IDocument.id ;
  exists : bool ;
  data   : Data.t ;
}

module Get = struct
  let id   t = t.id
  let data t = t.data
end

let empty id = 
  { id ; exists = false ; data = BatPMap.empty }

module Set = struct
  let data data t actor = 
    O.decay begin 
      let info = MUpdateInfo.self (MActor.avatar actor) in
      let id = DMS_IDocument.decay t.id in 
      if t.exists then 
	let diff = 
	  BatPMap.filteri 
	    (fun k v -> v <> (try BatPMap.find k t.data with Not_found -> Json.Null)) 
	    data 
	in 
	let! _ = ohm $ Store.update ~id ~diffs:[diff] ~info () in 
	return () 
      else
	let! _ = ohm $ Store.create ~id ~init:BatPMap.empty ~diffs:[data] ~info () in
	return ()
    end 
end

let get id = 
  O.decay begin 
    let! found = ohm_req_or (return (empty id)) (Store.get (DMS_IDocument.decay id)) in
    let  data = Store.current found in 
    return { id ; exists = true ; data }
  end 
