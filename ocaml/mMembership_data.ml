(* © 2012 MRunOrg *)

open Ohm
open Ohm.Universal

module Unique = MMembership_unique

module Data = struct
  module T = struct
    type json t = {
      data   "d" : (!string, Json.t) ListAssoc.t ;
      group  "g" : IGroup.t ;
      avatar "a" : IAvatar.t
    } 
  end
  include T
  include Fmt.Extend(T)
end

let init gid aid = Data.({
  data   = [] ;
  group  = IGroup.decay gid ;
  avatar = IAvatar.decay aid
})

module Config = struct

  let name = "membership-data"

  module DataDB    = CouchDB.Convenience.Config(struct let db = O.db "membership-data" end)
  module VersionDB = CouchDB.Convenience.Config(struct let db = O.db "membership-data-v" end)

  module Id = IMembership 

  module Data = Data

  module Diff = Fmt.Make(struct
    type json t = <
      self  "s"        : (!string, Json.t) ListAssoc.t ;
      admin "a"        : (!string, Json.t) ListAssoc.t ;
      irreversible "i" : (!string, Json.t) ListAssoc.t 
    >
  end)

  module ReflectedData = Fmt.Unit

  module VersionData = MUpdateInfo

  type ctx = O.ctx
  let couchDB ctx = (ctx :> CouchDB.ctx)

  let merge d l = 
    Data.({ 
      d with data = 
	List.fold_left (fun a (k,v) -> ListAssoc.replace k v a) d.data l
    })
    
  let apply (diff:Diff.t) = 
    return (fun _ _ t ->
      return (List.fold_left merge t [diff # self ; diff # admin ; diff # irreversible]))

  let reflect _ _ = return ()

end

module Store = OhmCouchVersioned.Make(Config)

let save_diffs gid aid info diffs = 
  let! mid = ohm $ Unique.find gid aid in
  let! _   = ohm $ Store.create
    ~id:(IMembership.decay mid) ~init:(init gid aid) ~diffs ~info ()
  in
  return ()

let restore_update gid aid data = 
  let info = MUpdateInfo.info ~who:`preconfig in
  save_diffs gid aid info [object
    method admin        = []
    method self         = data
    method irreversible = []
  end] 

let self_update gid aid info ?(irreversible=[]) data =

  let irreversible, self = 
    BatList.partition (fun (key,_) -> List.mem key irreversible) data
  in

  save_diffs gid aid info [object
    method admin        = []
    method self         = data 
    method irreversible = irreversible
  end]

let admin_update from gid aid info data = 
  save_diffs gid aid info [object
    method admin        = data
    method self         = []
    method irreversible = []
  end]

let get mid = 
  let! data = ohm_req_or (return []) $ Store.get (IMembership.decay mid) in
  return (Store.current data).Data.data

module Design = struct
  module Database = Store.DataDB
  let name = "data"
end

module ByField = Fmt.Make(struct
  type json t = (IGroup.t * string * Json.t)
end)

module ByFieldView = CouchDB.ReduceView(struct
  module Key     = ByField
  module Value   = Fmt.Int
  module Reduced = Fmt.Int
  module Design  = Design
  let name   = "statsByField"
  let map    = "for (var k in doc.c.d) {
                  var v = doc.c.d[k];                            
                  if (typeof v == 'object') 
                    for (var i in v) 
                      emit([doc.c.g,k,v[i]],1);
                  else
                    emit([doc.c.g,k,v],1);
                }" 
    let group = true 
    let level = None 
    let reduce = "return sum(values);" 
  end)

let count gid name =
  let  gid  = IGroup.decay gid in 
  let! list = ohm $ ByFieldView.reduce_query
    ~startkey:(gid,name,Json_type.Int min_int)
    ~endkey:(gid,name,Json_type.String "~~~~")
    ~endinclusive:true
    ()
  in
  return $ List.map (fun ((gid,field,value),count) -> value,count) list

let obliterate mid = Store.obliterate mid
