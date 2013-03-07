(* © 2013 RunOrg *)

type 'relation t = unit

type state = Ohm.Json.t

type fieldinfo = <
  label : O.i18n ;
  kind  : [ `TextShort  
	  | `TextLong
	  | `Date
	  | `PickOne of (string * O.i18n) list
	  | `PickMany of (string * O.i18n) list ]
> ;;

module All = struct
  let by_document _ = assert false
  let active _ _ = assert false
end

module Get = struct
  let id _ = assert false
  let iid _ = assert false
  let process _ = assert false
  let state _ = assert false
  let data _ = assert false
  let assignee _ = assert false
  let notified _ = assert false
  let created _ = assert false
  let updated _ = assert false
  let theState _ = assert false
  let finished _ = assert false
  let fields _ = assert false 
  let states _ = assert false
end

module Set = struct
  let state _ _ _ = assert false
  let data _ _ _ = assert false
  let assignee _ _ _ = assert false
  let addCC _ _ _ = assert false
  let delCC _ _ _ = assert false
end

let createIfMissing ~process ~actor _ = assert false
let get _ = assert false

