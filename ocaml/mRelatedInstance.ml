(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module MyUniqueDB = CouchDB.Convenience.Database(struct let db = O.db "related-instance-u" end)
module MyUnique = OhmCouchUnique.Make(MyUniqueDB)

let connection iid followed_iid =
  OhmCouchUnique.pair (IInstance.to_id iid) (IInstance.to_id followed_iid) 

module MyDB = CouchDB.Convenience.Database(struct let db = O.db "related-instance" end)

module Design = struct
  module Database = MyDB
  let name = "related"
end

module Unbound = struct
  module T = struct
    type json t = {
      name : string ;
      site : string option ;
      request : string ;
      owners : IUser.t list 
    }
  end
  include T
  include Fmt.Extend(T)
end

module Data = struct
  module T = struct
    module Float = Fmt.Float
    type json t = {
      related_to : IInstance.t ;
      created_by : IAvatar.t ;
      created_on : Float.t ;
      access     : [ `Public  "pub" 
		   | `Private "priv"] ;
      bind       : [ `Unbound "u" of Unbound.t
		   | `Bound   "b" of IInstance.t ] ;
     ?profile    : IInstance.t option 
    }
  end
  include T
  include Fmt.Extend(T)
end

module Tbl = CouchDB.Table(MyDB)(IRelatedInstance)(Data)

(* Signals --------------------------------------------------------------------------------- *)

module Signals = struct

  type owner_request = 
    [`IsSelf] IAvatar.id * [`Own] IRelatedInstance.id * string * IUser.t

  let add_owner_call, add_owner = Sig.make (Run.list_iter identity)

  module Connection = Fmt.Make(struct
    type json t = <
      relation : IRelatedInstance.t ;
      follower : IInstance.t ;
      followed : IInstance.t
    > ;;
  end)

  type connection = Connection.t

  let after_connect_call, after_connect = Sig.make (Run.list_iter identity) 

  let connect_call = 
    let task = O.async # define "after-network-connect" Connection.fmt begin fun c -> 

      let  lock_id = IRelatedInstance.to_id (c # relation) in
      let! lock = ohm $ MyUnique.lock (connection (c # follower) (c # followed)) lock_id in
            
      if lock = lock_id then
	after_connect_call c
      else
	Tbl.delete (c # relation)

    end in
    fun c -> task c
    
end

(* Description, used for rendering --------------------------------------------------------- *)

type description = <
  name        : string option ;
  site        : string option ;
  url         : [`None|`Site of string|`Key of IWhite.key|`Profile of IInstance.t] ;
  picture     : [`GetPic] IOldFile.id option ;
  access      : [ `Public | `Private ] ;
  profile     : IInstance.t option 
> ;;

let describe (t:Data.t) = 
  let bound = match t.Data.bind with 
    | `Bound   i -> `Bound i
    | `Unbound u -> match t.Data.profile with 
	| None   -> `Unbound u
	| Some i -> `Bound i
  in
  match bound with 
    | `Unbound u -> let o = object
                      method name        = Some u.Unbound.name
		      method picture     = None
		      method site        = u.Unbound.site
		      method access      = t.Data.access
		      method url         = match u.Unbound.site with None -> `None
                                            | Some url -> `Site url
		      method profile     = t.Data.profile
                    end in
		    return o
    | `Bound iid -> let empty = object
                      method name        = None
		      method site        = None
		      method url         = `None 
		      method picture     = None
		      method access      = t.Data.access
		      method profile     = t.Data.profile
                    end in 
		    let! prof = ohm_req_or (return empty) $ MInstance.Profile.get iid in 
		    let o = object
		      method name        = Some (prof # name) 
		      method picture     = prof # pic
		      method site        = prof # site
		      method access      = t.Data.access
		      method url         = if prof # unbound <> None
			                   then `Profile iid else `Key (prof # key)
		      method profile     = None
		    end in 
		    return o 
		      
let is_bound t = match t.Data.bind with 
  | `Unbound _ -> false
  | `Bound   _ -> true

(* Extracting ----------------------------------------------------------------------------- *)

module PublicView = CouchDB.DocView(struct
  module Key    = IInstance
  module Value  = Fmt.Unit
  module Doc    = Data
  module Design = Design
  let name = "public"
  let map  = "if (doc.access == 'pub') emit(doc.related_to,null)"
end)

module AllView = CouchDB.DocView(struct
  module Key    = IInstance
  module Value  = Fmt.Unit
  module Doc    = Data
  module Design = Design
  let name = "all"
  let map  = "emit(doc.related_to,null)"
end)

module ListenedView = CouchDB.MapView(struct
  module Key    = IInstance
  module Value  = IInstance
  module Design = Design
  let name = "listened"
  let map  = "if (doc.bind[0] == 'b') emit(doc.related_to,doc.bind[1])"
end)

module ListeningView = CouchDB.MapView(struct
  module Key    = IInstance
  module Value  = IInstance
  module Design = Design
  let name = "listening"
  let map  = "if (doc.bind[0] == 'b') emit(doc.bind[1],doc.related_to)"
end)

module MineView = CouchDB.DocView(struct
  module Key    = IUser
  module Value  = Fmt.Unit
  module Doc    = Data
  module Design = Design
  let name = "mine"
  let map  = "if (doc.bind[0] == 'u') {
                var u = doc.bind[1].owners; 
                for (var k = 0; k < u.length; ++k)
                 emit(u[k],null)
              }"
end)

type viewable = [`View] IRelatedInstance.id * Data.t

let assert_viewable item = 
  (* Access is checked by caller function *)
  IRelatedInstance.Assert.view (IRelatedInstance.of_id (item # id)), 
  item # doc

let get_all_public iid = 
  let! list = ohm $ PublicView.doc iid  in
  (* Anyone can see public items *)
  return $ List.rev_map assert_viewable list

let get_all iid = 
  let iid = IInstance.decay iid in 
  let! list = ohm $ AllView.doc iid in 
  (* Any member can see private items *)
  return $ List.rev_map assert_viewable list

let get_all_mine cuid = 
  let uid = IUser.Deduce.is_anyone cuid in 
  let! list = ohm $ MineView.doc uid in 
  (* I can always see items I own *)
  return $ List.rev_map assert_viewable list

let get_listened iid = 
  let! list = ohm $ ListenedView.by_key (IInstance.decay iid) in 
  return $ List.rev_map (#value) list 

let get_listeners iid = 
  let! list = ohm $ ListeningView.by_key (IInstance.decay iid) in 
  return $ BatList.unique (List.rev_map (#value) list) 

(* Accessing single items ----------------------------------------------------------------- *)

let get_data rid = Tbl.get (IRelatedInstance.decay rid) 

let get_follower rid = 
  let! data = ohm_req_or (return None) $ get_data rid in 
  return $ Some data.Data.related_to

let get actor rid = 
  let! data = ohm_req_or (return `None) $ Tbl.get (IRelatedInstance.decay rid) in

  if data.Data.related_to <> IInstance.decay (MActor.instance actor) then
    return `None
  else
    if 
      None <> MActor.admin actor
      || data.Data.created_by = IAvatar.decay (MActor.avatar actor)
    then
      (* We just found out it's an admin *)
      return $ `Admin (IRelatedInstance.Assert.admin rid, data) 
    else 
      match data.Data.access with
	| `Public -> 
	  (* It's public *)
	  return $ `View (IRelatedInstance.Assert.view rid, data) 
	| `Private -> 
	  if None <> MActor.member actor then
	    (* A member can view private related instances *)
	    return $ `View (IRelatedInstance.Assert.view rid, data)
	  else
	    return `None

let get_own cuid rid = 
  let  uid = IUser.Deduce.is_anyone cuid in 
  let! data = ohm_req_or (return None) $ Tbl.get (IRelatedInstance.decay rid) in 
  match data.Data.bind with 
    | `Bound   _ -> return None
    | `Unbound u -> if List.mem uid u.Unbound.owners then 
	(* We just found out it's an owner *)
	return $ Some (IRelatedInstance.Assert.own rid, data) 
      else
	return None

(* Ensure uniqueness and launch connect signal --------------------------------------------- *)

let connect rid iid iid' = 
  Signals.connect_call (object
    method relation = rid
    method follower = iid
    method followed = iid'
  end)

(* Mutators -------------------------------------------------------------------------------- *)

let bind_to rid iid = 
  let rid = IRelatedInstance.decay rid in
  let iid = IInstance.decay iid in 
  let update rid = 
    let! data = ohm_req_or (return (None,`keep)) $ Tbl.get rid in 
    match data.Data.bind with 
      | `Bound   _ -> return (None,`keep)
      | `Unbound _ -> return (Some data.Data.related_to,`put Data.({ data with bind = `Bound iid }))
  in
  let! iid' = ohm_req_or (return ()) $ Tbl.Raw.transaction rid update in
  connect rid iid' iid 

let decline rid uid = 
  let uid = IUser.Deduce.is_anyone uid in 
  let rid = IRelatedInstance.decay rid in
  let update rid = 
    let! data = ohm_req_or (return ((),`keep)) $ Tbl.get rid in 
    match data.Data.bind with 
      | `Bound   _ -> return ((),`keep)
      | `Unbound u -> return ((),`put Data.({ 
	data with bind = `Unbound Unbound.({
	  u with owners = BatList.remove u.owners uid 
	})
      }))
  in
  Tbl.Raw.transaction rid update

let follow iid aid followed_iid = 

  let  iid = IInstance.decay iid in 
  let! followed = ohm_req_or (return ()) $ MInstance.Profile.get followed_iid in
  
  let profile, bound =
    if followed # unbound <> None then 
      Some followed_iid, 
      `Unbound Unbound.({
	name  = followed # name ;
	site  = followed # site ;
	request = "" ;
	owners  = [] ; 
      })
    else
      None, 
      `Bound followed_iid
  in 

  let data = Data.({
    related_to = IInstance.decay iid ;
    created_by = IAvatar.decay aid ;
    created_on = Unix.gettimeofday () ;
    access     = `Public ;
    profile    ;
    bind       = bound
  }) in

  let! rid = ohm $ Tbl.create data in
  connect rid iid followed_iid

let create iid aid ~name ~request ~owners ~site ~access = 

  let data = Data.({
    related_to = IInstance.decay iid ;
    created_by = IAvatar.decay aid ;
    created_on = Unix.gettimeofday () ;
    access     ;
    profile    = None ;
    bind       = `Unbound Unbound.({
      name    ;
      site    ;
      request ;
      owners  ;
    })
  }) in

  let! rid = ohm $ Tbl.create data in

  let  rid = IRelatedInstance.Assert.own rid in 
  let!  _  = ohm $ Run.list_map
    (fun uid -> Signals.add_owner_call (aid,rid,request,uid)) owners
  in
  
  let  rid = IRelatedInstance.Assert.admin rid in 
  return rid

let update_unbound rid ~name ~site ~access = 
  let update data = 
    match data.Data.bind with 
      | `Bound   _ -> data
      | `Unbound u -> Data.({
	data with 
	  bind   = `Unbound Unbound.({ u with name ; site }) ;
	  access ;
      })
  in
  
  Tbl.update (IRelatedInstance.decay rid) update

let update_bound rid  ~access = 
  let update data = Data.({ data with access }) in
  Tbl.update (IRelatedInstance.decay rid) update

let send_requests rid aid request users = 
  let update rid =
    let! data = ohm_req_or (return ([],`keep)) $ Tbl.get rid in
    match data.Data.bind with 
      | `Bound   _ -> return ([],`keep)
      | `Unbound u -> let new_owners = 
			List.filter (fun uid -> not (List.mem uid u.Unbound.owners)) users
                      and obj = 
			Data.({ data with 
			  created_by = IAvatar.decay aid ;
			  bind       = `Unbound Unbound.({ u with owners = users ; request })
			})
		      in 
		      return (new_owners,`put obj)
  in

  let! owners = ohm $ Tbl.Raw.transaction (IRelatedInstance.decay rid) update in

  let  rid = IRelatedInstance.Assert.own rid in 
  let!  _  = ohm $ Run.list_map 
    (fun uid -> Signals.add_owner_call (aid,rid,request,uid))
    owners
  in

  return ()

module CountView = CouchDB.ReduceView(struct
  module Key = IInstance
  module Value = Fmt.Make(struct
    type json t = int * int
  end)
  module Design = Design
  let name = "count"
  let map  = "emit(doc.related_to,[1,0]); 
              if (doc.bind[0] == 'b') emit(doc.bind[1],[0,1]);"
  let reduce = "var r = [0,0];
                for (var i in values) { 
                  r[0] += values[i][0];
                  r[1] += values[i][1];
                }
                return r;"
  let group = true
  let level = None 
end)

let count iid = 

  let value (following,followers) = object
    method following = following
    method followers = followers
  end in 

  let! stats = ohm $ CountView.reduce (IInstance.decay iid) in 
  return $ value (BatOption.default (0,0) stats)

module Backdoor = struct

  module CountView = CouchDB.ReduceView(struct
    module Key = Fmt.Unit
    module Value = Fmt.Make(struct
      type json t = int * int
    end)
    module Design = Design
    let name = "backdoor-count"
    let map  = "emit(null,doc.bind[0] == 'b' ? [1,0] : [0,1]);"
    let reduce = "var r = [0,0];
                  for (var i in values) { 
                    r[0] += values[i][0];
                    r[1] += values[i][1];
                  }
                  return r;"
    let group = true
    let level = None 
  end)

  let count = 

    let value (bound,unbound) = object
      method bound   = bound
      method unbound = unbound
    end in 
    
    let! stats = ohm $ CountView.reduce () in 
    return $ value (BatOption.default (0,0) stats)

  module LatestView = CouchDB.DocView(struct
    module Key    = Fmt.Unit
    module Value  = Fmt.Unit
    module Doc    = Data
    module Design = Design
    let name = "backdoor-latest"
    let map  = "if (doc.bind[0] == 'u') emit(doc.created_on)"
  end)

  let latest = 
    let  limit = 50 in
    let! list  = ohm $ LatestView.doc_query ~descending:true ~limit () in
    return $ List.map (fun i -> IRelatedInstance.of_id (i#id), i#doc) list

  let set_profile riid iid = 

    let update data = Data.({ 
      data with 
	profile = if data.profile = None then Some iid else data.profile
    }) in

    let! () = ohm $ Tbl.update riid update in

    let! data = ohm_req_or (return ()) $ Tbl.get riid in 
    connect riid (data.Data.related_to) iid

end
