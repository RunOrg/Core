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
  let! avatar, group = Sig.listen MDelegation.Signals.is_in_group in  
  let! id    = ohm_req_or (return false) $ Unique.find_if_exists group avatar in
  let! value = ohm_req_or (return false) $ Versioned.get id in
  return (`Member = (Versioned.reflected value).Reflected.status)

let () = 
  let! avatar, state, group = Sig.listen MAvatarStream.Signals.is_in_group in  
  let! id    = ohm_req_or (return false) $ Unique.find_if_exists group avatar in
  let! value = ohm_req_or (return false) $ Versioned.get id in
  return ((state :> Status.t) = (Versioned.reflected value).Reflected.status)

(* List elements in a group --------------------------------------------------------------- *)

module MembersView = CouchDB.MapView(struct
  module Key    = Fmt.Make(struct
    type json t = (IAvatarSet.t * Status.t * IAvatar.t)
  end)
  module Value  = Fmt.Unit
  module Design = Versioned.Design
  let name = "members"
  let map  = "emit([doc.c.where,doc.r.status,doc.c.who]);"
end)

let list_members_by_status status ?start ~count group = 
  let group = IAvatarSet.decay group in 

  let limit    = count + 1 in
  let startkey = (group,status,BatOption.default IAvatar.smallest start) in
  let endkey   = (group,status,IAvatar.largest) in
  
  let !list = ohm $ MembersView.query 
    ~startkey 
    ~endkey
    ~limit
    ~endinclusive:true
    ()
  in

  return (OhmPaging.slice ~count (List.map (#key %> (fun (_,_,aid) -> aid)) list))

let list_members ?start ~count group = 
  list_members_by_status `Member ?start ~count group

module EveryoneView = CouchDB.MapView(struct
  module Key    = IAvatarSet
  module Value  = IAvatar
  module Design = Versioned.Design
  let name = "everyone"
  let map  = "emit (doc.c.where, doc.c.who);"
end)

let list_everyone ?start ~count group = 
  let group = IAvatarSet.decay group in 

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

(* Return avatars for access reversal ---------------------------------------------------- *)

let () = 
  let! iid, status, asid, start, count = Sig.listen MAvatarStream.Signals.all_in_group in 

  (* Make sure the group exists and belongs to the instance. *)
  let! avset = ohm_req_or (return []) (MAvatarSet.naked_get asid) in
  let! () = true_or (return []) (MAvatarSet.Get.instance avset = IInstance.decay iid) in

  let! list, next = ohm $ list_members_by_status (status :> Status.t) ?start ~count asid in
  return (match next with Some aid -> aid :: list | None -> list) 

(* List avatars in a group --------------------------------------------------------------- *)

module AvatarView = CouchDB.MapView(struct
  module Key    = Fmt.Make(struct
    type json t = (IAvatarSet.t * IAvatar.t)
  end)
  module Value  = Fmt.Unit
  module Design = Versioned.Design
  let name = "avatars"
  let map  = "if (doc.r.status !== 'NotMember') emit ([doc.c.where,doc.c.who], null);"
end)

let avatars gid ~start ~count = 
  let gid      = IAvatarSet.decay gid in 
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

  let list = List.map (#key %> snd) list in 

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
  module Key     = IAvatarSet
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

let count asid = 
  let! result = ohm_req_or (return zero_count) $ CountView.reduce (IAvatarSet.decay asid) in
  return result
