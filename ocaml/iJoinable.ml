(* © 2012 RunOrg *)

type t = [ `Entity of IEntity.t
	 | `Event  of IEvent.t ]

let to_string = function
  | `Entity eid -> "t" ^ IEntity.to_string eid
  | `Event  eid -> "e" ^ IEvent.to_string eid

let of_string s = 
  let s' = BatString.lchop s in
  if s.[0] = 't' then 
    Some (`Entity (IEntity.of_string s'))
  else if s.[0] = 'e' then 
    Some (`Event (IEvent.of_string s'))
  else 
    None

let arg = to_string, of_string
