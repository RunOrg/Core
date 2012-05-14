(* © 2012 MRunOrg *)

open Ohm
open Ohm.Util
open Ohm.Universal
open BatPervasives

module Method = Fmt.Make(struct
  type json t = 
    [ `Cash 
    | `Transfer
    | `AutoBill
    | `Card
    | `Paypal
    | `Cheque
    | `Other ]
end)

let all_methods = 
  [ `Cash ;
    `Transfer ;
    `AutoBill ;
    `Card ;
    `Paypal ;
    `Cheque ;
    `Other ]

module Data = struct
  module T = struct
    module Float = Fmt.Float
    module IAvatar = IAvatar
    module IEntity = IEntity
    module IInstance = IInstance
    type json t = 
	{
	 ?join      : bool = false ;
	 ?what      : [`label of string | `text of string] = `text "" ;
	 ?mode      : Method.t = `Other ;
	 ?subscribe : bool = false ;
	  reference : string option ;
	  canceled  : (IAvatar.t option * Float.t) option ;
	  amount    : int ;
	  payer     : IAvatar.t option ;
	  creator   : IAvatar.t option ;
	  comment   : string ;
	  created   : float ;
	  paid      : string ;
	  instance  : IInstance.t ;
	  entity    : IEntity.t option ;
	  direction : [`In|`Out]
	}
  end
  include T
  include Fmt.Extend(T)
end

type where = 
  [ `Instance of [`IsAdmin] IInstance.id
  | `Entity of [`Admin] IEntity.id * IInstance.t 
  ]
    
module VersionedConfig = struct
  let name = "accountLine"
  module DataDB = CouchDB.Convenience.Config(struct let db = O.db "account-line" end)
  module Id = IAccountLine
  module VersionDB = CouchDB.Convenience.Config(struct let db = O.db "account-line-v" end)
  module Data = Data

  module Diff = Fmt.Make(struct
    module IAvatar = IAvatar
    type json t =
      [ `Cancel of IAvatar.t option
      | `Update of <
	 ?what      : [`label of string | `text of string] = `text "" ;
	  comment   : string ;
	  reference : string option
        >
      ]
  end)

  let apply = function
    | `Cancel a -> return (fun _ time t -> return Data.({ t with canceled = Some (a,time) }))
    | `Update u -> return (fun _ _ t ->
      return Data.({ t with
	what      = u # what ;
	comment   = u # comment ;
	reference = u # reference
      })
    )

  module VersionData = Fmt.Make(struct
    module IAvatar = IAvatar
    type json t = <
      who : [ `user of IAvatar.t | `auto ]
    >
  end)

  module ReflectedData = Fmt.Unit

  let reflect _ _ = return ()

end

module Store = OhmCouchVersioned.Make(VersionedConfig)

let info_of_user user = object
  method who = match user with 
    | None -> `auto
    | Some avatar -> `user (IAvatar.decay avatar) 
end

let create ~what ~subscribe ~join ~where ~mode ~direction ~amount ~time ~payer ~creator ~reference ~comment = 

  let id = IAccountLine.gen () in

  let info = info_of_user creator in

  let init = Data.({   
    subscribe ; 
    what ;
    join ;
    reference ;
    mode ;
    canceled = None ;
    amount ; 
    payer ;
    creator = BatOption.map IAvatar.decay creator ;
    comment ;
    created = Unix.gettimeofday () ;
    paid = time ;
    instance = ( match where with
      | `Instance  iid  -> IInstance.decay iid
      | `Entity (_,iid) -> iid ) ;
    entity = ( match where with 
      | `Instance    _  -> None
      | `Entity (eid,_) -> Some (IEntity.decay eid) ) ;
    direction 
  }) in

  let! data = ohm (Store.create ~id ~init ~diffs:[] ~info ()) in
  return (IAccountLine.Assert.view id, Store.current data) 

let is_visible where line = 
  match where with 
    | `Instance iid -> 
      line.Data.instance = IInstance.decay iid
    | `Entity (eid,iid) -> 
      line.Data.instance = IInstance.decay iid 
      && line.Data.entity = Some (IEntity.decay eid)

module MyDatabase = Store.DataDB
module MyTable = CouchDB.ReadTable(MyDatabase)(IAccountLine)(Store.Raw)
let cancel where id who = 

  let! current = ohm_req_or (return ()) (MyTable.get id) in
  let! ()      = true_or (return ()) (is_visible where (current # current)) in

  let info     = info_of_user who in 

  let diffs    = [ `Cancel (BatOption.map IAvatar.decay who) ] in
  
  let! _       = ohm (Store.update ~id ~diffs ~info ()) in

  return ()

let update where id ~who ~what ~reference ~comment = 

  let! current = ohm_req_or (return ()) (MyTable.get id) in
  let! ()      = true_or (return ()) (is_visible where (current # current)) in

  let info = info_of_user who in 

  let diffs = [
    `Update (object
      method what = what
      method comment = comment
      method reference = reference
    end)
  ] in

  let! _ = ohm (Store.update ~id ~diffs ~info ()) in
  return ()

module Design = struct
  module Database = MyDatabase
  let name = "account-line"
end

module StatsByInstance = CouchDB.ReduceView(struct
  module Key = IInstance
  module Value = Fmt.Make(struct
    type json t = < total_in : int ; total_out : int >
  end)
  module Design = Design
  let name = "stats_by_instance"
  let map  = "if (!doc.c.canceled) 
                emit(doc.c.instance,{
                  total_in  : doc.c.direction == 'In'  ? doc.c.amount : 0,
                  total_out : doc.c.direction == 'Out' ? doc.c.amount : 0
                });"
  let reduce = "var r = { total_in : 0, total_out : 0 };
                for (var i in values) {
                  r.total_in += values[i].total_in ;
                  r.total_out += values[i].total_out ;
                }
                return r;"    
  let group = true
  let level = None
end)

module StatsByEntity = CouchDB.ReduceView(struct
  module Key = IEntity
  module Value = Fmt.Make(struct
    type json t = < total_in : int ; total_out : int >
  end)
  module Design = Design
  let name = "stats_by_entity"
  let map  = "if (!doc.c.canceled && doc.c.entity) 
                emit(doc.c.entity,{
                  total_in  : doc.c.direction == 'In'  ? doc.c.amount : 0,
                  total_out : doc.c.direction == 'Out' ? doc.c.amount : 0
                });"
  let reduce = "var r = { total_in : 0, total_out : 0 };
                for (var i in values) {
                  r.total_in += values[i].total_in ;
                  r.total_out += values[i].total_out ;
                }
                return r;"    
  let group = true
  let level = None
end)

let default = object
  method total_in  = 0
  method total_out = 0
end

let totals where = 
  match where with 
    | `Instance iid ->

      let! totals = ohm (StatsByInstance.reduce (IInstance.decay iid)) in
      return (BatOption.default default totals)

    | `Entity (eid,_) ->

      let! totals = ohm (StatsByEntity.reduce (IEntity.decay eid)) in
      return (BatOption.default default totals)
	
let get id = 
  let  id   = IAccountLine.decay id in 
  let! line = ohm_req_or (return None) (MyTable.get id) in
  return (Some (line # current)) 

let try_get where id = 
  let! line    = ohm_req_or (return None) (MyTable.get id) in
  let  line    = line # current in 
  let  visible = is_visible where line in
  if visible then return (Some (
    IAccountLine.Assert.view id, (* We hold the appropriate 'where' to see/edit it *)
    line
  )) else return None

module ListByInstance = CouchDB.DocView(struct
  module Key = IInstance
  module Value = Fmt.Unit
  module Doc = Store.Raw
  module Design = Design
  let name = "list_by_instance"
  let map  = "if (!doc.c.canceled) emit(doc.c.instance,null);"
end)

module ListByEntity = CouchDB.DocView(struct
  module Key = IEntity
  module Value = Fmt.Unit
  module Doc = Store.Raw
  module Design = Design
  let name = "list_by_entity"
  let map  = "if (!doc.c.canceled && doc.c.entity) emit(doc.c.entity,null);"
end)

let get_all where = 

  let! list = ohm (
    match where with
      | `Instance iid   -> ListByInstance.doc (IInstance.decay iid)
      | `Entity (eid,_) -> ListByEntity.doc (IEntity.decay eid)
  ) in	

  return (List.map (fun item ->
    IAccountLine.Assert.view (IAccountLine.of_id (item # id)) ,
    item # doc # current
  ) list)
