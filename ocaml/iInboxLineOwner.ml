(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal

type 'a id = 
  [ `Event of 'a IEvent.id 
  ]

include Fmt.Make(struct 
  type json t = 
    [ `Event "e" of IEvent.t
    ]
end) 

let decay = function 
  | `Event eid -> `Event (IEvent.decay eid) 

let to_id = function
  | `Event eid -> IEvent.to_id eid 

