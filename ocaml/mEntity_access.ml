(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal

module Get = MEntity_get

module Format = Fmt.Make(struct
  type json t = [ `Viewers | `Registered | `Managers ]
end) 


let viewers    entity = `Entity (IEntity.decay $ Get.id entity,`View)
let registered entity = `Groups (`Validated,[Get.group entity])
let managers   entity = `Entity (IEntity.decay $ Get.id entity,`Manage) 

let make entity = function
  | `Viewers    -> viewers entity
  | `Registered -> registered entity
  | `Managers   -> managers entity 

let rec which = function
  | `Entity (_,`View)        -> `Viewers
  | `Groups (`Validated,[_]) -> `Registered  
  | `Entity (_,`Manage)      -> `Managers
  | `TokOnly t               -> which t
  | _                        -> `Managers

