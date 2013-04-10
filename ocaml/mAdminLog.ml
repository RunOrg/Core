(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

(* Data type definitions ----------------------------------------------------------------------------------- *)

module Payload = struct    
  module T = struct
    type json t = 
        MembershipMass          "mm"  of 
	    [ `Invite "i" | `Add "a" | `Remove "r" | `Validate "v" | `Create "c" ] * 
	      [ `Event "e" of IEvent.t | `Group "g" of IGroup.t ] * int
      | MembershipAdmin         "ma"  of 
	  [ `Invite "i" | `Add "a" | `Remove "r" | `Validate "v" ] * 
	    [ `Event "e" of IEvent.t | `Group "g" of IGroup.t ] * IAvatar.t
      | MembershipUser          "mu"  of bool * [ `Event "e" of IEvent.t | `Group "g" of IGroup.t ] 
      | InstanceCreate          "ic"
      | LoginManual             "lm"
      | LoginSignup             "ls"
      | LoginWithNotify         "ln"  of INotif.Plugin.t
      | LoginWithReset          "lr"
      | UserConfirm             "uc"
      | ItemCreate              "it"  of IItem.t
      | CommentCreate           "cc"  of IComment.t 
      | BroadcastPublish        "bp"  of [ `Post "p" | `Forward "f" ] * IBroadcast.t
      | SendMail                "m"   
  end
  include T
  include Fmt.Extend(T)
end

module Data = Fmt.Make(struct
  type json t = <
    uid  : IUser.t ;
    iid  : IInstance.t option ;
    what : Payload.t ;
    time : float
  >
end)

type t = Data.t 

(* Database definition --------------------------------------------------------------------- *)

include CouchDB.Convenience.Table(struct let db = O.db "alog" end)(Id)(Data)

let log ?id ~uid ?iid ?time payload = 

  let! now  = ohmctx (#time) in
  let  time = BatOption.default now time in 
  let  data = object
    method uid  = uid
    method iid  = iid
    method time = time
    method what = payload
  end in 

  match id with 
    | None -> Run.map ignore (Tbl.create data)
    | Some id -> Tbl.set id data 

(* Stats extraction ----------------------------------------------------------------------- *)

module Stats = struct

  include Fmt.Make(struct

    type json t = <
      instanceCreate : int ;
      login : < manual : int ; signup : int ; notify : int ; reset : int > ;
      confirm : int ;
      post : < item : int ; comment : int ; broadcast : int ; forward : int > ;
      mail : int ;
    >
  end)

  module Count = CouchDB.ReduceView(struct
    module Key = Fmt.Make(struct type json t = (float option) end) 
    module Value = Fmt.Make(struct type json t = (!string,int) ListAssoc.t end)
    module Design = Design
    let name = "stats"
    let map = "var k = (typeof doc.what === 'string') ? doc.what : doc.what[0];
               if (k == 'ec') k += doc.what[1];
               if (k == 'bp') k += doc.what[1];
               var o = {};
               o[k] = 1;
               emit(doc.time,o);"
    let reduce = "var r = {}; 
                  for (var i = 0; i < values.length; ++i)  
                    for (var k in values[i]) 
                      r[k] = (r[k] || 0) + values[i][k];
                  return r;"
    let group = false
    let level = None
  end)

end

let stats days_ago = 
  let! time = ohmctx (#time) in
  let  day  = 3600. *. 24. in
  let  endkey   = time -. (float_of_int days_ago *. day) in
  let  startkey = endkey -. day in

  let! data = ohm $ Stats.Count.reduce_query
    ~startkey:(Some startkey)
    ~endkey:(Some endkey) 
    ~endinclusive:false () 
  in

  let  stats = match data with (_, stats) :: _ -> stats | _ -> [] in
  let  map   = BatPMap.of_enum (BatList.enum stats) in
  let  count key = try BatPMap.find key map with _ -> 0 in 

  return (object
    method instanceCreate = count "ic"
    method login = (object
      method manual = count "lm"
      method signup = count "ls"
      method notify = count "ln"
      method reset  = count "lr"
    end)
    method confirm = count "uc"
    method post = (object
      method item = count "ic"
      method comment = count "cc"
      method broadcast = count "bpp"
      method forward = count "bpf"
    end)
    method mail = count "m"
  end)

module CountActiveUsers = CouchDB.ReduceView(struct
  module Key = Fmt.Make(struct type json t = float option end) 
  module Value = Fmt.Make(struct type json t = string list end)
  module Design = Design
  let name = "active_users"
  let map = "var k = (typeof doc.what === 'string') ? doc.what : doc.what[0];
             if (k != 'm') 
               emit(doc.time,[doc.uid])"
  let reduce = "var r = {}; 
                for (var i = 0; i < values.length; ++i)  
                  for (var j = 0; j < values[i].length; ++j)
                    r[values[i][j]] = true;
                var o = [];
                for (var k in r) o.push(k);
                return o;"
  let group = false
  let level = None
end)

let active_users ~period = 
  let! now = ohmctx (#time) in
  let  startkey = Some (now -. period) in
  let! list = ohm $ CountActiveUsers.reduce_query ~startkey () in
  return $ List.length (List.concat (List.map snd list))

module CountActiveInstances = CouchDB.ReduceView(struct
  module Key = Fmt.Make(struct type json t = float option end) 
  module Value = Fmt.Make(struct type json t = string option list end)
  module Design = Design
  let name = "active_instances"
  let map = "if (doc.iid) emit(doc.time,[doc.iid])"
  let reduce = "var r = {}; 
                for (var i = 0; i < values.length; ++i)  
                  for (var j = 0; j < values[i].length; ++j)
                    if (values[i][j])
                      r[values[i][j]] = true;
                var o = [], k = null;
                for (k in r) o.push(k);
                return o;"
  let group = false
  let level = None
end)

let active_instances ~period = 
  let! now = ohmctx (#time) in
  let  startkey = Some (now -. period) in
  let! list = ohm $ CountActiveInstances.reduce_query ~startkey () in
  return $ List.length 
    (BatList.sort_unique compare
       (List.concat (List.map snd list)))
