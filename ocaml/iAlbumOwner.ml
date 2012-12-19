(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal

type 'a id = 
  [ `Event  of 'a IEvent.id 
  | `Entity of 'a IEntity.id
  ]

include Fmt.Make(struct 
  type json t = 
    [ `Event  "e" of IEvent.t
    | `Entity "n" of IEntity.t 
    ]
end) 

let decay = function 
  | `Event  eid -> `Event  (IEvent.decay  eid) 
  | `Entity eid -> `Entity (IEntity.decay eid) 

let to_id = function
  | `Event  eid -> IEvent.to_id  eid 
  | `Entity eid -> IEntity.to_id eid
