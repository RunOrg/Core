(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Cfg = struct

  let name = "event-data"

  module DataDB = struct
    let database = O.db "event-data"
    let host = "localhost"
    let port = 5984
  end

  module VersionDB = struct
    let database = O.db "event-data-v"
    let host = "localhost"
    let port = 5984
  end

  module Id = IEvent

  module Diff = Fmt.Make(struct
    type json t =
      [ `SetAddress of string option 
      | `SetPage    of MRich.OrText.t 
      ]
  end) 

  module Data = struct
    module T = struct
      type json t = {
	address : string option ;
	page    : [ `R of MRich.OrText.t ]
      }
    end
    include T
    include Fmt.Extend(T)
  end

  type ctx = O.ctx

  let couchDB ctx = (ctx : O.ctx :> CouchDB.ctx)

  module VersionData = MUpdateInfo
  module ReflectedData = Fmt.Unit

  let do_apply t = Data.(function 
    | `SetAddress address -> { t with address }
    | `SetPage    page    -> { t with page = `R page }
  )
    
  let apply diff = 
    return (fun _ _ t -> return (do_apply t diff))

  let reflect _ _ = return ()

end

module Store = OhmCouchVersioned.Make(Cfg)

type 'relation t = Cfg.Data.t

let get eid = 
  Run.edit_context (fun ctx -> (ctx :> O.ctx)) begin 
    let! proj = ohm_req_or (return None) $ Store.get (IEvent.decay eid) in
    return $ Some (Store.current proj)
  end

let update eid self ~address ~page = 

  let! current = ohm_req_or (return ()) (get eid) in

  O.decay begin

    let info = MUpdateInfo.self (MActor.avatar self) in
    let eid  = IEvent.decay eid in 

    let diffs = BatList.filter_map identity [
      (if address = current.Cfg.Data.address then None else Some (`SetAddress address)) ;
      (if `R page = current.Cfg.Data.page then None else Some (`SetPage page)) 
    ] in

    if diffs = [] then 
      return () 
    else 
      let! _ = ohm $ Store.update ~id:eid ~diffs ~info () in
      return () 

  end

let address t = 
  t.Cfg.Data.address

let page t = 
  match t.Cfg.Data.page with 
    | `R page -> page

let create eid ?address ?(page=`Text "") self =
  O.decay begin 

    let eid  = IEvent.decay eid in
    let info = MUpdateInfo.self (MActor.avatar self) in 

    let init = Cfg.Data.({
      address ;
      page    = `R page ;
    }) in

    let! _ = ohm $ Store.create ~id:eid ~init ~diffs:[] ~info () in
    return () 

  end
