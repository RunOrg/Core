(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

(* Core module --------------------------------------------------------------------------------------------- *)

module type CORE = sig
  type t 
  type diff 
  module Id  : Ohm.CouchDB.ID
  module Raw : Ohm.Fmt.READ_FMT with type t = t 
  module Tbl : Ohm.CouchDB.READ_TABLE with type id = Id.t and type elt = Raw.t
  module Design : Ohm.CouchDB.DESIGN 
  val update : Id.t -> 'any MActor.t -> diff list -> (O.ctx,unit) Ohm.Run.t
  val create : Id.t -> 'any MActor.t -> Raw.t -> diff list -> (O.ctx,unit) Ohm.Run.t 
end 

module type CORE_ARG = 
  OhmCouchVersioned.VERSIONED with type ctx = O.ctx and type VersionData.t = MUpdateInfo.info

module Core = functor(V:CORE_ARG) -> struct

  type t = V.Data.t
  type diff = V.Diff.t
  module Id = V.Id

  module Store = OhmCouchVersioned.Make(V)

  module Raw = struct
    module T = struct
      type t = V.Data.t
      let t_of_json json = 
	(Store.Raw.of_json json) # current
    end
    include T
    include Fmt.ReadExtend(T)
  end 

  module Tbl = CouchDB.ReadTable(Store.DataDB)(Id)(Raw)
  module Design = struct
    module Database = Store.DataDB
    let name = V.name
  end
    
  let update id actor diffs = 
    let info = MUpdateInfo.self (MActor.avatar actor) in
    let! _ = ohm $ Store.update ~id ~diffs ~info () in
    return () 

  let create id actor init diffs = 
    let info = MUpdateInfo.self (MActor.avatar actor) in
    let! _ = ohm $ Store.create ~id ~init ~diffs ~info () in
    return () 

end

(* Access ("can") module ----------------------------------------------------------------------------------- *)

module type CAN = sig 

  type core 
  type 'a id 

  type 'relation t
    
  val make : 'a id -> ?actor:'any MActor.t -> core -> 'a t option 

  val id   : 'any t -> 'any id
  val data : 'any t -> core  
  val uid  : 'any t -> [`Unknown] id     
  
  val view_access   : 'any t -> MAccess.t list
  val admin_access  : 'any t -> MAccess.t list 
    
  val view  : 'any t -> (#O.ctx,[`View]  t option) Ohm.Run.t 
  val admin : 'any t -> (#O.ctx,[`Admin] t option) Ohm.Run.t 
    
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

  let uid t = C.decay t.id
    
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
    O.decay (S.update (C.uid t) self diffs) 
end
