(* © 2013 RunOrg *)

type 'a id = 
  [ `Event      of 'a IEvent.id 
  | `Discussion of 'a IDiscussion.id 
  | `Newsletter of 'a INewsletter.id
  ]

include Ohm.Fmt.FMT with type t = [`Unknown] id 

val decay : 'a id -> t 

val to_id : 'a id -> Ohm.Id.t
