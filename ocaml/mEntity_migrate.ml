(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

module E = MEntity_core

let kind = E.Store.migrate O.async "entity.migrate.kind"
  begin fun eid data -> 
    let tid  = data.E.Init.template in
    let kind = PreConfig_Template.kind tid in 
    if kind = data.E.Init.kind then return None else
      return $ Some E.Init.({ data with kind })
  end

let () = O.put (kind ())
