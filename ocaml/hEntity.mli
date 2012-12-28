(* © 2012 RunOrg *)

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

module Can : functor(C:CAN_ARG) -> CAN with type core = C.core and type 'a id = 'a C.id

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

module Set : functor(C:CAN) -> functor(S:SET_ARG with type Id.t = [`Unknown] C.id) ->
  SET with type 'a can = 'a C.t and type diff = S.Diff.t

