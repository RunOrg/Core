(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Versioned = MMembership_versioned
module Status    = MMembership_status
module Unique    = MMembership_unique 
module Reflected = MMembership_reflected

(* Find a member status by its group + avatar --------------------------------------------- *)

let () = 
  let! avatar, group, expect = Sig.listen MAccess.Signals.in_group in  
  let! id    = ohm_req_or (return false) $ Unique.find_if_exists group avatar in
  let! value = ohm_req_or (return false) $ Versioned.get id in
  let  valid = `Member    = (Versioned.reflected value).Reflected.status in
  let  out   = `NotMember = (Versioned.reflected value).Reflected.status in
  match expect with 
    | `Any       -> return (not out) 
    | `Pending   -> return (not out && not valid)
    | `Validated -> return valid

(* List elements in a group --------------------------------------------------------------- *)

module AllView = CouchDB.MapView(struct
  module Key    = Fmt.Make(struct
    type json t = (IGroup.t * bool)
  end)
  module Value  = IAvatar
  module Design = Versioned.Design
  let name = "all"
  let map  = "emit ([doc.c.where,doc.r.status === 'Member'], doc.c.who);"
end)

let all group access = 
  let group = IGroup.decay group in 
  let first, last = match access with 
    | `Pending   -> false, false
    | `Validated -> true,  true
    | `Any       -> false, true
  in

  let! list = ohm $ AllView.query
    ~startkey:(group,first) 
    ~endkey:(group,last)
    ~endinclusive:true
    ()
  in

  return $ List.map (fun i -> snd (i # key), i # value) list

let list_members ?start ~count group = 
  let group = IGroup.decay group in 

  let startid  = start in
  let limit    = count + 1 in
  let startkey = (group,true) in
  let endkey   = (group,true) in
  
  let !list = ohm $ AllView.query 
    ~startkey 
    ~endkey
    ?startid
    ~limit
    ~endinclusive:true
    ()
  in

  let rec extract n = function
    | [] -> None, []
    | h :: t -> 
      if n = 0 then Some h, [] else 
	let last, rest = extract (n-1) t in 
	last, h :: rest 
  in
  
  let last, rest = extract count list in 
  
  let last = BatOption.map (#id) last in
  let rest = List.map (#value) rest in 
    
  return (rest, last)

module EveryoneView = CouchDB.MapView(struct
  module Key    = IGroup
  module Value  = IAvatar
  module Design = Versioned.Design
  let name = "everyone"
  let map  = "emit (doc.c.where, doc.c.who);"
end)

let list_everyone ?start ~count group = 
  let group = IGroup.decay group in 

  let startid  = start in
  let limit    = count + 1 in
  let startkey = group in
  let endkey   = group in
  
  let !list = ohm $ EveryoneView.query 
    ~startkey 
    ~endkey
    ?startid
    ~limit
    ~endinclusive:true
    ()
  in

  let rec extract n = function
    | [] -> None, []
    | h :: t -> 
      if n = 0 then Some h, [] else 
	let last, rest = extract (n-1) t in 
	last, h :: rest 
  in
  
  let last, rest = extract count list in 
  
  let last = BatOption.map (#id) last in
  let rest = List.map (#value) rest in 
  
  return (rest, last)

(* List avatars in a group --------------------------------------------------------------- *)

module AvatarView = CouchDB.MapView(struct
  module Key    = Fmt.Make(struct
    type json t = (IGroup.t * IAvatar.t)
  end)
  module Value  = Fmt.Unit
  module Design = Versioned.Design
  let name = "avatars"
  let map  = "if (doc.r.status !== 'NotMember') emit ([doc.c.where,doc.c.who], null);"
end)

let avatars gid ~start ~count = 
  let gid      = IGroup.decay gid in 
  let limit    = count + 1 in
  let startkey = (gid,BatOption.default IAvatar.smallest start) in
  let endkey   = (gid,IAvatar.largest) in
  
  let !list = ohm $ AvatarView.query 
    ~startkey 
    ~endkey
    ~limit
    ~endinclusive:true
    ()
  in

  let list = List.map (#key |- snd) list in 

  let rec extract n = function
    | [] -> [], None
    | h :: t -> 
      if n = 0 then [], Some h else 
	let rest, last = extract (n-1) t in 
	h :: rest, last 
  in
  
  return $ extract count list
  
(* Count elements in a group -------------------------------------------------------------- *)

module Count = Fmt.Make(struct
  type json t = <
    count "c"   : int ;
    pending "p" : int ;
    any "a"     : int
  >
end) 

module CountView = CouchDB.ReduceView(struct
  module Key     = IGroup
  module Value   = Count
  module Reduced = Count
  module Design  = Versioned.Design
  let name   = "count"
  let map    = "var c = (doc.r.status === 'Member') ? 1 : 0;
                var p = (doc.r.status === 'Pending') ? 1 : 0;
                var a = (doc.r.status !== 'NotMember') ? 1 : 0;
                if (c > 0 || p > 0) emit(doc.c.where,{c:c,p:p,a:a})" 
  let group  = true 
  let level  = None 
  let reduce = "var r = { c:0, p:0, a:0 } ; 
                for (var k in values) {
                  r.c += values[k].c ;
                  r.p += values[k].p ;
                  r.a += values[k].a ;
                }
                return r;" 
end)

let zero_count = object 
  method count   = 0
  method pending = 0
  method any     = 0
end

let count group = 
  let! result = ohm_req_or (return zero_count) $ CountView.reduce (IGroup.decay group) in
  return result
