(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

type 'relation t = 'relation MGroup_can.t

module Vision    = MGroup_vision 
module Signals   = MGroup_signals
module Can       = MGroup_can 
module Get       = MGroup_get
module Satellite = MGroup_satellite
module Set       = MGroup_set
module Config    = MGroup_config
module All       = MGroup_all
module Initial   = MGroup_initial
module E         = MGroup_core
module Create    = MGroup_create
module Atom      = MGroup_atom

let create = Create.public

include HEntity.Get(Can)(E)

let delete t self = 
  let! () = ohm $ Set.update [`Delete (IAvatar.decay (MActor.avatar self))] t self in
  O.decay (Signals.on_delete_call (IGroup.decay (Get.id t), Get.group t))

let instance eid = 
  let! event = ohm_req_or (return None) (get eid) in
  return $ Some (Get.iid event)

let admin_name ?actor iid = 
  let  pcnamer = MPreConfigNamer.load iid in 
  let  default = `label `EntityAdminName in
  let! gid     = ohm $ MPreConfigNamer.group IGroup.admin pcnamer in 
  let! group   = ohm_req_or (return default) $ view ?actor gid in 
  return (BatOption.default default (Get.name group))   

module Backdoor = struct
  let refresh_atoms cuid = 
    Atom.refresh_atoms cuid 
end
