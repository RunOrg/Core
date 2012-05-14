(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal

let get i18n avatar = 
  match avatar # name with 
    | Some name -> name
    | None -> I18n.translate i18n (`label "anonymous") 

let of_entity entity = 
  match MEntity.Get.name entity with 
    | Some n -> n
    | None   -> `label "entity.untitled"
