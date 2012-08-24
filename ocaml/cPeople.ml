(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let box_content ?url access group = 
  let  gid = MGroup.Get.id group in 
  O.Box.fill $ O.decay begin 
    let! avatars, _ = ohm $ MMembership.InGroup.list_members ~count:100 gid in
    CAvatar.directory ?url avatars
  end
    
let event_box ?url access group =
  match group with 
    | None -> O.Box.fill (return ignore) 
    | Some group -> box_content ?url access group

let forum_box ?url access group =
  match group with 
    | None -> O.Box.fill (return ignore) 
    | Some group -> box_content ?url access group
