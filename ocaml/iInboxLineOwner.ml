(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal

type 'a id = 
  [ `Event      of 'a IEvent.id 
  | `Discussion of 'a IDiscussion.id 
  | `Newsletter of 'a INewsletter.id
  ]

include Fmt.Make(struct 
  type json t = 
    [ `Event      "e" of IEvent.t
    | `Discussion "d" of IDiscussion.t
    | `Newsletter "n" of INewsletter.t
    ]
end) 

let decay = function 
  | `Event      eid -> `Event      (IEvent.decay      eid) 
  | `Discussion did -> `Discussion (IDiscussion.decay did) 
  | `Newsletter nid -> `Newsletter (INewsletter.decay nid)

let to_id = function
  | `Event      eid -> IEvent.to_id      eid 
  | `Discussion did -> IDiscussion.to_id did 
  | `Newsletter nid -> INewsletter.to_id nid

