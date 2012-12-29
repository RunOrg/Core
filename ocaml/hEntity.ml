(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

(* Core module --------------------------------------------------------------------------------------------- *)

module CoreDefaults = struct
end

module type CORE = sig
  type t 
  type diff 
  module Id  : Ohm.CouchDB.ID
  module Raw : Ohm.Fmt.READ_FMT with type t = t 
  module Tbl : Ohm.CouchDB.READ_TABLE with type id = Id.t and type elt = Raw.t
  module Design : Ohm.CouchDB.DESIGN 
  val update : Id.t -> 'any MActor.t -> diff list -> (O.ctx,unit) Ohm.Run.t
  val create : Id.t -> 'any MActor.t -> Raw.t -> diff list -> (O.ctx,unit) Ohm.Run.t 
  val on_update : (Id.t,unit O.run) Ohm.Sig.channel 
end 

module type CORE_ARG = sig
  val name : string
  module Id : Ohm.CouchDB.ID
  module Data : Ohm.Fmt.FMT
  module Diff : Ohm.Fmt.FMT
  val apply : Diff.t -> (Id.t -> float -> Data.t -> Data.t O.run) O.run
end

module Core = functor(C:CORE_ARG) -> struct

  module V = struct

    include C

    module DataDB = struct
      let database = O.db name
      let host = "localhost"
      let port = 5984
    end

    module VersionDB = struct
      let database = O.db (name ^ "-v") 
      let host = "localhost"
      let port = 5984
    end
      
    type ctx = O.ctx
    let couchDB ctx = (ctx : O.ctx :> CouchDB.ctx) 
    module VersionData = MUpdateInfo
    module ReflectedData = Fmt.Unit
    let reflect _ _ = return () 

  end

  type t = C.Data.t
  type diff = C.Diff.t
  module Id = C.Id

  module Store = OhmCouchVersioned.Make(V)

  module Raw = struct
    module T = struct
      type t = C.Data.t
      let t_of_json json = 
	(Store.Raw.of_json json) # current
    end
    include T
    include Fmt.ReadExtend(T)
  end 

  module Tbl = CouchDB.ReadTable(Store.DataDB)(Id)(Raw)
  module Design = struct
    module Database = Store.DataDB
    let name = C.name
  end
    
  let update id actor diffs = 
    let info = MUpdateInfo.self (MActor.avatar actor) in
    let! _ = ohm $ Store.update ~id ~diffs ~info () in
    return () 

  let create id actor init diffs = 
    let info = MUpdateInfo.self (MActor.avatar actor) in
    let! _ = ohm $ Store.create ~id ~init ~diffs ~info () in
    return () 

  let on_update_call, on_update = Sig.make (Run.list_iter identity) 

  let () = 
    let! t = Sig.listen Store.Signals.version_create in
    on_update_call (Store.version_object t) 

end

(* Access ("can") module ----------------------------------------------------------------------------------- *)

module type CAN = sig 

  type core 
  type 'a id 

  type 'relation t
    
  val make : 'a id -> ?actor:'any MActor.t -> core -> 'a t option 

  val id   : 'any t -> 'any id
  val data : 'any t -> core  
  
  val view_access   : 'any t -> MAccess.t list
  val admin_access  : 'any t -> MAccess.t list 
    
  val view  : 'any t -> (#O.ctx,[`View]  t option) Ohm.Run.t 
  val admin : 'any t -> (#O.ctx,[`Admin] t option) Ohm.Run.t 

  val decay : 'any id -> [`Unknown] id 

end

module type CAN_ARG = sig
  type core
  type 'a id
  val deleted : core -> bool
  val iid : core -> IInstance.t
  val admin : core -> MAccess.t list 
  val view : core -> MAccess.t list
  val id_view  : 'a id -> [`View] id
  val id_admin : 'a id -> [`Admin] id  
  val decay : 'a id -> [`Unknown] id 
  val public : core -> bool 
end

module Can = functor (C:CAN_ARG) -> struct

  type core = C.core
  type 'a id = 'a C.id

  let decay id = C.decay id 

  type 'relation t = {
    id    : 'relation id ;
    data  : core ;
    actor : [`IsToken] MActor.t option ;
  }

  let valid ?actor data = 
    not (C.deleted data) && begin
      match actor with 
	| None -> true
	| Some actor -> IInstance.decay (MActor.instance actor) = C.iid data 
    end

  let make id ?actor data = if valid ?actor data then Some {
    id ;
    data ;
    actor = BatOption.bind MActor.member actor ;
  } else None
  
  let admin_access t = 
    C.admin t.data 

  let view_access t = 
    C.view t.data  

  let id t = t.id
    
  let data t = t.data
    
  let view t = 
    O.decay begin 
      let t' = { id = C.id_view t.id ; data = t.data ; actor = t.actor } in   
      match t.actor with 
	| None -> if C.public t.data then return (Some t') else return None
	| Some actor -> let! ok = ohm $ MAccess.test actor (view_access t) in
			if ok then return (Some t') else return None
    end
      
  let admin t = 
    O.decay begin
      let t' = { id = C.id_admin t.id ; data = t.data ; actor = t.actor } in
      match t.actor with 
	| None       -> return None
	| Some actor -> let! ok = ohm $ MAccess.test actor (admin_access t) in
			if ok then return (Some t') else return None
    end

end

(* Mutation ("set") module ---------------------------------------------------------------------------------- *)

module type SET = sig
  type 'a can  
  type diff 
  type ('a,'ctx) t = [`Admin] can -> 'a MActor.t -> ('ctx,unit) Ohm.Run.t
  val update : diff list -> ('any,#O.ctx) t
end

module Set = functor(C:CAN) -> functor(S:CORE with type Id.t = [`Unknown] C.id) -> struct
  type 'a can = 'a C.t
  type diff = S.diff
  type ('a,'b) t = [`Admin] can -> 'a MActor.t -> ('b,unit) Ohm.Run.t
  let update diffs t self =
    O.decay (S.update (C.decay (C.id t)) self diffs) 
end

(* Load ("get") module -------------------------------------------------------------------------------------- *)

module Get = functor(C:CAN) -> functor(S:CORE with type Id.t = [`Unknown] C.id and type t = C.core) -> struct

  let get ?actor id = 
    O.decay (let! e = ohm_req_or (return None) $ S.Tbl.get (C.decay id) in
	     return (C.make id ?actor e))

  let view ?actor id = 
    let! e = ohm_req_or (return None) (get ?actor id) in
    C.view e

  let admin ?actor id = 
    let! e = ohm_req_or (return None) (get ?actor id) in
    C.admin e

end
