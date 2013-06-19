(* © 2013 RunOrg *)
  
open Ohm
open Ohm.Universal
open BatPervasives
  
module Core = MNewsletter_core
module Can  = MNewsletter_can

include HEntity.Set(Can)(Core)

let edit ~title ~body t self = 
  let e = Can.data t in 
  let diffs = BatList.filter_map identity [
    (if title = e.Core.title then None else Some (`SetTitle title)) ;
    (if body  = e.Core.body  then None else Some (`SetBody body)) ;
  ] in
  if diffs = [] then return () else update diffs t self 

let send gids t self = 

  let! asids = ohm (Run.list_filter begin fun gid -> 
    let! group = ohm_req_or (return None) (MGroup.get gid) in
    return (Some (MGroup.Get.group group)) 
  end gids) in 

  let e = Can.data t in
  let asids = List.filter (fun asid -> not (List.exists (fun (asid',_) -> asid = asid') e.Core.gids)) asids in
  
  if asids = [] then return () else update [ `Send asids ] t self
