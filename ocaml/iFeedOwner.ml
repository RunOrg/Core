(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal

type 'a id = 
  [ `Event      of 'a IEvent.id 
  | `Entity     of 'a IEntity.id
  | `Instance   of 'a IInstance.id 
  | `Discussion of 'a IDiscussion.id 
  ]

include Fmt.Make(struct 
  type json t = 
    [ `Event      "e" of IEvent.t
    | `Entity     "n" of IEntity.t 
    | `Instance   "i" of IInstance.t 
    | `Discussion "d" of IDiscussion.t 
    ]
end) 

let decay = function 
  | `Event      eid -> `Event      (IEvent.decay      eid) 
  | `Entity     eid -> `Entity     (IEntity.decay     eid) 
  | `Instance   iid -> `Instance   (IInstance.decay   iid) 
  | `Discussion did -> `Discussion (IDiscussion.decay did) 

let to_id = function
  | `Event      eid -> IEvent.to_id      eid 
  | `Entity     eid -> IEntity.to_id     eid
  | `Instance   iid -> IInstance.to_id   iid
  | `Discussion did -> IDiscussion.to_id did

