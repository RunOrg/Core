(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Assoc = Fmt.Make(struct
  type t = (string,Json.t) BatPMap.t
  let json_of_t t = 
    Json.Object (BatPMap.foldi (fun k v l -> (k,v) :: l) t [])
  let t_of_json json = 
    List.fold_left (fun m (k,v) -> BatPMap.add k v m) BatPMap.empty 
      (Json.to_assoc json) 
end)

module Task = struct
  module T = struct
    type json t = {
      iid : IInstance.t ;
      did : DMS_IDocument.t ;
      active : bool ;
      process : PreConfig_Task.ProcessId.DMS.t ;
      data : Assoc.t ;
      assignee : IAvatar.t option ;
      notified : IAvatar.t list ;
      created : (IAvatar.t * float) ;
      state : (Json.t * IAvatar.t * float) ;
    }
  end
  include T
  include Fmt.Extend(T)
end

let clean m = 
  BatPMap.filter ((<>) Json.Null) m 

module Cfg = struct
    
  let name = "dms-doctask"

  module DataDB = struct
    let database = O.db name
    let host     = "localhost"
    let port     = 5984
  end

  module VersionDB = struct
    let database = O.db name ^ "-v"
    let host     = "localhost"
    let port     = 5984 
  end

  type ctx = O.ctx
  let couchDB ctx = (ctx : O.ctx :> CouchDB.ctx)

  module Id = DMS_IDocTask
  module Data = Task
  module Diff = Fmt.Make(struct
    type json t = 
      [ `SetState of Json.t * IAvatar.t
      | `SetAssignee of IAvatar.t option
      | `SetNotified of IAvatar.t list
      | `SetData of Assoc.t
      ]
  end)

  let apply_state (state,aid) _ time data = 
    return Data.({ data with 
      state  = (state, aid, time) ;
      active = not ((PreConfig_Task.DMS.states data.process) # final state)
    })

  let apply_assignee aidopt _ _ data = 
    return Data.({ data with assignee = aidopt })

  let apply_notified aids _ _ data = 
    return Data.({ data with notified = aids })

  let apply_data assoc _ _ data = 
    return Data.({ data with data = clean (BatPMap.foldi BatPMap.add assoc data.data) })

  let apply = function
    | `SetState state -> return (apply_state state) 
    | `SetAssignee aidopt -> return (apply_assignee aidopt) 
    | `SetNotified aids -> return (apply_notified aids)
    | `SetData data -> return (apply_data data)

  module VersionData = MUpdateInfo
  module ReflectedData = Fmt.Unit
  let reflect _ _ = return () 

end

module Store = OhmCouchVersioned.Make(Cfg)

type t = Task.t = {
  iid : IInstance.t ;
  did : DMS_IDocument.t ;
  active : bool ;
  process : PreConfig_Task.ProcessId.DMS.t ;
  data : Assoc.t ;
  assignee : IAvatar.t option ;
  notified : IAvatar.t list ;
  created : (IAvatar.t * float) ;
  state : (Json.t * IAvatar.t * float) ;
}
