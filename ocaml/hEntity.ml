(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

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

module type SET = sig
  type 'a can  
  type diff 
  type ('a,'ctx) t = [`Admin] can -> 'a MActor.t -> ('ctx,unit) Ohm.Run.t
  val update : diff list -> ('any,#O.ctx) t
end

module type SET_ARG = sig
  type t 
  module Id : Ohm.CouchDB.ID
  module Diff : Ohm.Fmt.FMT
  val update : id:Id.t -> diffs:Diff.t list -> info:MUpdateInfo.t -> unit -> (O.ctx,t option) Ohm.Run.t
end

module Set = functor(C:CAN) -> functor(S:SET_ARG with type Id.t = [`Unknown] C.id) -> struct
  type 'a can = 'a C.t
  type diff = S.Diff.t
  type ('a,'b) t = [`Admin] can -> 'a MActor.t -> ('b,unit) Ohm.Run.t
  let update diffs t self =
    O.decay begin 
      let info = MUpdateInfo.self (MActor.avatar self) in
      let! _ = ohm $ S.update ~id:(C.uid t) ~diffs ~info () in
      return () 
    end 
end
