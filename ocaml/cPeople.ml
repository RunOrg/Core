(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let event_box_content access group = 
  let  gid = MGroup.Get.id group in 
  O.Box.fill $ O.decay begin 
    let! avatars, _ = ohm $ MMembership.InGroup.avatars gid ~start:None ~count:100 in
    CAvatar.directory avatars
  end
    
let event_box access group =
  match group with 
    | None -> O.Box.fill (return $ Html.str "")
    | Some group -> event_box_content access group
