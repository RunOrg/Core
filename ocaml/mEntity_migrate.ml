(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

module E = MEntity_core

let kind = E.Store.migrate O.async "entity.migrate.kind"
  begin fun eid data -> 
    let tid  = data.E.Init.template in
    let kind = PreConfig_Template.kind tid in
    let draft = match kind with `Event -> true | _ -> false in 
    if kind = data.E.Init.kind && draft = data.E.Init.draft 
    then return None 
    else return $ Some E.Init.({ data with kind ; draft })
  end

let () = O.put (kind ())
