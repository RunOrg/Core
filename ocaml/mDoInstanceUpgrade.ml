(* © 2012 MRunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

let () = 

  let! iid, diffs = Sig.listen MInstance.Signals.on_upgrade in

  let iid = IInstance.Assert.bot iid in 

  let namer  = MPreConfigNamer.load iid in 
  let entity name = 
    let! eid = ohm $ MPreConfigNamer.entity name namer in
    (* Working on this entity *)
    return (IEntity.Assert.bot eid)
  in

  let! _ = ohm $ Run.list_map begin function
    | `Entities (`Create c) -> MEntity.bot_create iid c |> Run.map ignore
    | `Entities (`Update u) -> let! eid   = ohm $ entity (u # name) in
			       MInstanceEntity.update [`Update u] (MEntity.bot_update eid)
    | `Entities (`Config c) -> let! eid   = ohm $ entity (c # name) in
			       MInstanceEntity.update [`Config c] (MEntity.bot_update eid)
    | `Propagate p          -> MGroupPropagate.apply MGroup.Propagate.upgrade namer p 
  end diffs in

  return ()

