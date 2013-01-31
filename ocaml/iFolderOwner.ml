(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal

type 'a id = 
  [ `Event      of 'a IEvent.id 
  | `Entity     of 'a IEntity.id
  | `Discussion of 'a IDiscussion.id
  ]

include Fmt.Make(struct 
  type json t = 
    [ `Event      "e" of IEvent.t
    | `Entity     "n" of IEntity.t 
    | `Discussion "d" of IDiscussion.t
    ]
end) 

let decay = function 
  | `Event      eid -> `Event      (IEvent.decay      eid) 
  | `Entity     eid -> `Entity     (IEntity.decay     eid) 
  | `Discussion did -> `Discussion (IDiscussion.decay did) 

let to_id = function
  | `Event      eid -> IEvent.to_id      eid 
  | `Entity     eid -> IEntity.to_id     eid
  | `Discussion did -> IDiscussion.to_id did 
