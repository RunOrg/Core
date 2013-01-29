(* © 2013 RunOrg *)

type t = [ `Group  of IGroup.t
	 | `Event  of IEvent.t ]

let to_string = function
  | `Group gid -> "g" ^ IGroup.to_string gid
  | `Event eid -> "e" ^ IEvent.to_string eid

let of_string s = 
  let s' = BatString.lchop s in
  if s.[0] = 'g' then 
    Some (`Group (IGroup.of_string s'))
  else if s.[0] = 'e' then 
    Some (`Event (IEvent.of_string s'))
  else 
    None

let arg = to_string, of_string
