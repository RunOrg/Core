(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Grid    = MAvatarGrid

let box access entity render = 
  
  let fail = render (return ignore) in 

  (* Extract the AvatarGrid identifier *)

  let  draft  = MEntity.Get.draft entity in 

  let  gid = MEntity.Get.group entity in
  let! group = ohm $ O.decay (MGroup.try_get access gid) in
  let! group = ohm $ O.decay (Run.opt_bind MGroup.Can.list group) in
  let  group = if draft then None else group in   
  let! group = req_or fail group in 

  let  grid  = MGroup.Get.list group in 
  let  lid   = Grid.list_id grid in
  
  let! columns = ohm $ O.decay (
    let! columns, _, _ = ohm_req_or (return []) $ Grid.MyGrid.get_list lid in    
    return columns
  ) in

  let body = Asset_Grid_Edit.render (object
    method columns = List.map MAvatarGridColumn.(fun c -> TextOrAdlib.to_string c.label) columns
  end) in

  render body
