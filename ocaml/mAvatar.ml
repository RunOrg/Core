(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

(* Including submodules ------------------------------------------------------------------- *)

module Common  = MAvatar_common
module Unique  = MAvatar_unique
module Status  = MAvatar_status
module Signals = MAvatar_signals
module Pending = MAvatar_pending
module Details = MAvatar_details
module Notify  = MAvatar_notify

(* Data types & formats ------------------------------------------------------------------- *)

module MyDB   = Common.MyDB
module Tbl    = Common.Tbl
module Design = Common.Design

include Common.Data

module InsSta = Fmt.Make(struct
  type json t = (IInstance.t * Status.t)
end) 

module UsrSta = Fmt.Make(struct
  type json t = (IUser.t * Status.t)
end) 

module Search = Fmt.Make(struct
  type json t = (IInstance.t * string)
end)

(* Refresh avatar cached data ------------------------------------------------------------- *)

let email_username email = 
  try let index = BatString.find email "@" in
      let prefix = BatString.head email (index+1) in
      prefix ^ "..."
  with Not_found -> email 

let collect ~lastname ~firstname ~email ~picture = 
  let ln = Util.fold_all lastname and fn = Util.fold_all firstname in
  (object
    method name    = 
      if lastname = "" then
	if firstname = "" then BatOption.map email_username email
	else Some firstname
      else
	if firstname = "" then Some lastname
	else Some (firstname ^ " " ^ lastname)
    method picture = BatOption.map IFile.decay picture
    method role    = None
    method sort    =   
      if ln = "" then
	if fn = "" then 
	  match BatOption.map email_username email with 
	    | None -> []
	    | Some raw -> [ Util.fold_all raw ]
	else [ fn ]
      else
	if fn = "" then [ ln ]
	else [ ln ; fn ; ln ^ " " ^ fn ; fn ^ " " ^ ln ]
   end)

let collect_profile details = 
  MProfile.Data.(
    collect 
      ~lastname:details.lastname
      ~firstname:details.firstname
      ~email:details.email
      ~picture:details.picture 
  )

let self_data iid uid =
  let default = object 
    method name    = None
    method picture = None
    method role    = None
    method sort    = []
  end in
  let! profile = ohm $ MProfile.find_or_create iid uid in
  let! details = ohm $ MProfile.details (IProfile.Assert.is_self profile) in 
  match details with  
    | None         -> return default
    | Some details -> return $ collect 
      ~lastname:(details # lastname)
      ~firstname:(details # firstname)
      ~email:(details # email)
      ~picture:(details # picture)
      	
(* Details : extracted from the database when looking for details about an avatar --------- *)

include Details

(* Extraction ----------------------------------------------------------------------------- *)

let exists aid = 
  let  aid    = IAvatar.decay aid in 
  let! avatar = ohm $ Tbl.get aid in 
  return (avatar <> None)

let get_raw ins usr = 
  let! aid    = ohm $ Unique.get ins usr in 
  let! avatar = ohm $ Tbl.get aid in 
  return (aid, avatar) 

let actor_of_avatar aid avatar = 
  let iid = avatar # ins in 
  let role = avatar # sta in
  let uid = IUser.Assert.is_old (avatar # who) in
  MActor.Make.contact ~role ~aid ~iid ~uid 

let actor aid = 
  let! avatar = ohm_req_or (return None) $ Tbl.get (IAvatar.decay aid) in 
  return $ Some (actor_of_avatar aid avatar)

(* Status updates ------------------------------------------------------------------------- *)

let update_status status ins usr =

  let ins = IInstance.decay ins in
  let usr = IUser.decay usr in
  
  let! aid = ohm $ Unique.get ins usr in
  
  let update = function
    | None -> 
      let  newsta = status None in 
      let! data   = ohm $ self_data ins usr in
      let! _      = ohm $ Pending.invite ~uid:usr ~iid:ins aid in
      return (true, `put (object
	(* Definition *)
	method t       = `Avatar
	method who     = usr
	method ins     = ins
	(* Own data *)
	method sta     = newsta
	(* Cached data *)
	method name    = data # name
	method picture = data # picture
	method sort    = data # sort
	method role    = data # role
      end))
     
    | Some obj -> 
      let  newsta = status (Some (obj # sta)) in
      return (
	if obj # sta = newsta
	then false, `keep 
	else true, `put (object	
	  (* Definition *)
	  method t       = `Avatar
	  method who     = usr
	  method ins     = ins
	  (* Own data *)
	  method sta     = newsta
	  (* Cached data *)
	  method name    = obj # name
	  method picture = obj # picture
	  method sort    = obj # sort
	  method role    = obj # role
	end)
      )
  in
  
  let! changed = ohm $ Tbl.transact aid update in
  let! () = ohm $ Signals.on_update_call (aid, ins) in
  
  return (aid, changed)
				       
let update_avatar_status status ?ins avatar =

  let avatar = IAvatar.decay avatar in
  let update obj = 
    let newsta = status (obj # sta) in
    if obj # sta = newsta || ins <> None && Some (obj # who, obj # ins) <> ins
    then None, `keep 
    else Some (obj # who, obj # ins), `put (object	
      (* Definition *)
      method t       = `Avatar
      method who     = obj # who
      method ins     = obj # ins
      (* Own data *)
      method sta     = newsta
      (* Cached data *)
      method name    = obj # name
      method picture = obj # picture
      method sort    = obj # sort
      method role    = obj # role
    end)
  in
  
  let! result = ohm $ Tbl.transact avatar
    (function 
      | None      -> return (None,`keep)
      | Some data -> return (update data)) 
  in
  let! () = ohm begin 
    match result with 
      | None         -> return ()
      | Some (_,iid) -> Signals.on_update_call (avatar, iid)
  end in
  return result

let upgrade how avatar = 
  let! _ = ohm (update_avatar_status how avatar) in
  return () 

let eventful_upgrade how signal ?from avatar =
  let! uid, iid = ohm_req_or (return ()) $ update_avatar_status how avatar in
  match from with None -> return () | Some from ->
    let from = IAvatar.decay from in 
    if from = IAvatar.decay avatar then return () else 
      signal ~uid ~iid ~from

let upgrade_to_admin ?from aid = 
  eventful_upgrade (fun _ -> `Admin) Notify.upgrade_to_admin ?from aid 
      
let upgrade_to_member ?from aid = 
  eventful_upgrade (function `Admin -> `Admin | _ -> `Token) Notify.upgrade_to_member ?from aid 

let downgrade_to_contact ?from aid = 
  upgrade (fun _ -> `Contact) aid  

let downgrade_to_member ?from aid = 
  upgrade (function `Contact -> `Contact | _ -> `Token) aid

let change_to_member ?from avatar = 
  let! current = ohm_req_or (return ()) $ Tbl.get (IAvatar.decay avatar) in
  match current # sta with 
    | `Admin   -> downgrade_to_member ?from avatar
    | `Contact
    | `Token   -> upgrade_to_member ?from avatar

let become_contact instance user = 
  let! id, _ = ohm $
    update_status (function 
      | Some `Admin -> `Admin
      | Some `Token -> `Token
      | _ -> `Contact) instance user 
  in
  return id

let become_admin instance user =
  let! id, _ = ohm $ update_status (fun _ -> `Admin) instance user in
  return id

(* Identify an user for an instance ------------------------------------------------------- *)

let status iid cuid = 
  let  uid = IUser.Deduce.is_anyone cuid in
  let  iid = IInstance.decay iid in 
  let! aid, avatar = ohm $ get_raw iid uid in
  return $ BatOption.default `Contact (BatOption.map (#sta) avatar)

let identify iid cuid = 
  let! aid, avatar = ohm $ get_raw (IInstance.decay iid) (IUser.Deduce.is_anyone cuid) in
  let! avatar = req_or (return None) avatar in 
  return $ Some (actor_of_avatar aid avatar)

let find iid uid = 
  let! aid, avatar = ohm $ get_raw (IInstance.decay iid) (IUser.decay uid) in
  if avatar = None then return None else return (Some aid) 

let profile aid = 
  let  selfsame = IProfile.of_string (IAvatar.to_string aid) in
  let! a        = ohm_req_or (return selfsame) $ Tbl.get (IAvatar.decay aid) in
  let! pid      = ohm_req_or (return selfsame) $ MProfile.find (a#ins) (a#who) in
  return pid 

let my_profile aid = 
  let! pid = ohm $ profile aid in 
  (* Acting as self *)
  return (IProfile.Assert.is_self pid)

(* List all members of an instance -------------------------------------------------------- *)

module MembersView = CouchDB.DocView(struct
  module Key = Fmt.Make(struct
    type json t = (IInstance.t * string)
  end)

  module Value  = Fmt.Unit
  module Doc    = Common.Data
  module Design = Design
  let name = "members" 
  let map  = "if (doc.t == 'avtr' && (doc.sta == 'mbr' || doc.sta == 'own')) 
    if (doc.sort.length > 0) emit([doc.ins,doc.sort[0]],null)" 
end)

let list_members ?start ~count instance = 

  let instance = IInstance.decay instance in 

  let limit = count + 1 in
  let startkey = instance, BatOption.default "" start in
  let endkey   = IInstance.next instance, "" in 

  let! members = ohm $
    MembersView.doc_query 
    ~startkey
    ~endkey
    ~limit
    ~endinclusive:false
    ()
  in
  
  let rec extract n = function
    | [] -> None, []
    | h :: t -> 
      if n = 0 then Some h, [] else 
	let last, rest = extract (n-1) t in 
	last, h :: rest 
  in
  
  let last, rest = extract count members in 
    
  let last = BatOption.map (#key |- snd) last in 
  let rest = List.map (#id |- IAvatar.of_id) rest in 
  
  return (rest, last)

(* List all administrators ---------------------------------------------------------------- *)

module AdminsView = CouchDB.DocView(struct
  module Key = Fmt.Make(struct
    type json t = (IInstance.t * string)
  end)

  module Value  = Fmt.Unit
  module Doc    = Common.Data
  module Design = Design
  let name = "admins" 
  let map  = "if (doc.t == 'avtr' && doc.sta == 'own') 
    if (doc.sort.length > 0) emit([doc.ins,doc.sort[0]],null)" 
end)

let list_administrators ?start ~count instance = 

  let instance = IInstance.decay instance in 

  let limit = count + 1 in
  let startkey = instance, BatOption.default "" start in
  let endkey   = IInstance.next instance, "" in 

  let! members = ohm $
    AdminsView.doc_query 
    ~startkey
    ~endkey
    ~limit
    ~endinclusive:false
    ()
  in
  
  let rec extract n = function
    | [] -> None, []
    | h :: t -> 
      if n = 0 then Some h, [] else 
	let last, rest = extract (n-1) t in 
	last, h :: rest 
  in
  
  let last, rest = extract count members in 
    
  let last = BatOption.map (#key |- snd) last in 
  let rest = List.map (#id |- IAvatar.of_id) rest in 
  
  return (rest, last)


(* List extractions ----------------------------------------------------------------------- *)

module ContactsView = CouchDB.DocView(struct
  module Key = Fmt.Make(struct
    type json t = (IInstance.t * string)
  end)

  module Value  = Fmt.Unit
  module Doc    = Common.Data
  module Design = Design
  let name = "contacts" 
  let map  = "if (doc.t == 'avtr') 
    if (doc.sort.length > 0) emit([doc.ins,doc.sort[0]],null)" 
end)
  
module SearchView = CouchDB.DocView(struct
  module Key    = Search
  module Value  = Fmt.Unit
  module Doc    = Common.Data
  module Design = Design
  let name = "search"
  let map  = "if (doc.t == 'avtr') for (var k in doc.sort) emit([doc.ins,doc.sort[k]],null)"
end)

let search iid name count = 

  let iid = IInstance.decay iid in

  if name = "" then 
    
    let limit = count in
    let startkey = iid, "" in
    let endkey   = IInstance.next iid, "" in 
    
    let! list = ohm $ ContactsView.doc_query 
      ~startkey
      ~endkey
      ~limit
      ~endinclusive:false
      ()
    in

    return $ BatList.filter_map begin fun item ->
      let i = item # id and d = item # doc and p = snd (item # key) in
      if d # name <> None then 
	Some (IAvatar.of_id i , p , Details.from d)
      else
	None
    end list    
    
  else

    let name = Util.fold_all name in 
    let! list = ohm $ SearchView.doc_query 
      ~startkey:(iid, name) 
      ~limit:((count+1) * 2)
      ()
    in

    let found = Hashtbl.create count in
    
    return $ BatList.filter_map begin fun item ->
      let i = item # id and d = item # doc and p = snd (item # key) in
      try Hashtbl.find found i ; None with Not_found -> 
	Hashtbl.add found i () ;
	if BatString.starts_with p name then
	  if d # name <> None then 
	    Some (IAvatar.of_id i , p , Details.from d)
	  else
	    None
	else
	  None
    end list      

(* User instances ------------------------------------------------------------------------- *)

module ByUserView = CouchDB.MapView(struct
  module Key = UsrSta
  module Value = IInstance
  module Design = Design
  let name = "by_user"
  let map  = "if (doc.t == 'avtr') emit([doc.who,doc.sta],doc.ins)"
end)

let user_instances ?status ?count usr = 

  let  usr     = IUser.decay usr in 
  let  startkey, endkey = match status with 
    | None   -> (usr,`Contact), (usr,`Admin) (* ctc < mbr < own *)
    | Some s -> (usr,s), (usr,s)
  in

  let! avatars = ohm $ ByUserView.query ~startkey ~endkey ?limit:count () in
  return $
    List.map begin fun item ->
      let _, sta = item # key in
      let ins    = item # value in 
      sta, 
      (* If you have an avatar, you're at least a contact. *)
      IInstance.Assert.is_contact ins
    end avatars

let is_admin ?other_than uid = 
  let  count = if other_than = None then 2 else 1 in
  let! list  = ohm $ user_instances ~status:`Admin ~count uid in 
  let  iids  = List.map (snd |- IInstance.decay) list in 
  return $ List.exists (fun iid -> other_than <> Some iid) iids

let user_avatars uid = 

  let  uid = IUser.decay uid in 
  let  startkey = (uid,`Token) and endkey = (uid,`Admin) in
  let! list = ohm $ ByUserView.query ~startkey ~endkey ~limit:200 () in
  
  Run.list_filter begin fun item ->
    let  iid = item # value and aid = IAvatar.of_id item # id in
    let  _, sta = item # key in 
    let  aid = IAvatar.Assert.is_self aid in
    let  uid = IUser.Assert.is_old uid in
    return (MActor.member (MActor.Make.contact ~iid ~aid ~uid ~role:sta))
  end list 
      
module CountByUserView = CouchDB.ReduceView(struct
  module Key    = IUser
  module Value  = Fmt.Int
  module Design = Design
  let name   = "count by_user"
  let map    = "if (doc.t == 'avtr' && (doc.sta == 'mbr' || doc.sta == 'own')) emit(doc.who,1)"
  let reduce = "return sum(values)"
  let group  = true
  let level  = None
end)

let count_user_instances uid =
  let  uid = IUser.decay uid in
  let! n   = ohm $ CountByUserView.reduce uid in
  return $ BatOption.default 0 n 

(* MAccess by status ----------------------------------------------------------------------- *)

module ByStatusView = CouchDB.MapView(struct
  module Key    = InsSta
  module Value  = Fmt.Unit
  module Design = Design
  let name = "by_status" 
  let map  = "if (doc.t == 'avtr') {
                switch (doc.sta) {
                  case 'own': emit([doc.ins,'own']); 
                  case 'mbr': emit([doc.ins,'mbr']);
                  case 'ctc': emit([doc.ins,'ctc']);
                  default: return;
                }
              }" 
end)

let by_status iid ?start ~count status = 
  let key = (IInstance.decay iid, status) in
  let! list = ohm $ ByStatusView.query
    ~startkey:key
    ~endkey:key 
    ?startid:(BatOption.map IAvatar.to_id start)  
    ~limit:(count + 1) 
    ~endinclusive:true
    ()
  in 
  return $ OhmPaging.slice ~count (List.map (fun item -> IAvatar.of_id item # id) list)

(* Refreshing profile. -------------------------------------------------------------------- *)

let _ = 

  let task = O.async # define "refresh-avatars" Id.fmt 
    begin fun id ->

      (* We are acting as the user to do these updates. *)
      let uid      = IUser.Assert.bot (IUser.of_id id) in
      
      let! list = ohm $ user_instances (IUser.Deduce.view_inst uid) in
      
      Run.list_iter (snd |- MProfile.refresh uid) list

  end in

  let! id, _ = Sig.listen MUser.Signals.on_update in 
  task (IUser.to_id id)

let _ = 

  let! _, uid, iid, data = Sig.listen MProfile.Signals.on_update in 
  let! aid = ohm_req_or (return ()) $ Unique.get_if_exists iid uid in
  
  let data = collect_profile data in

  let update avatar = 
    if 
      data # name <> avatar # name 
      || data # picture <> avatar # picture
      || data # sort <> avatar # sort
      || data # role <> avatar # role
    then 	
      true, `put (object
	  (* Definition *)
	method t       = `Avatar
	method who     = avatar # who 
	method ins     = avatar # ins
	  (* Own data *)
	method sta     = avatar # sta
	  (* Cached data *)
	method name    = data # name
	method picture = data # picture
	method sort    = data # sort
	method role    = data # role
      end) 
    else
      false, `keep
  in
  
  let! changed = ohm $ Tbl.transact aid 
    (function 
      | None -> return (false,`keep)
      | Some data -> return (update data))
  in
  
  let! () = ohm begin 
    if changed then match data # name with 
      | None -> return () 
      | Some name -> MAtom.reflect iid `Avatar (IAvatar.to_id aid) name
    else return () 
  end in 

  Signals.on_update_call (aid,iid)

(* Obliterate all avatars for an user ----------------------------------------------------- *)

let avatars_of_user uid = 
  let! list = ohm $ ByUserView.query ~startkey:(uid,`Contact) ~endkey:(uid,`Admin) () in
  return $ List.map (#id |- IAvatar.of_id) list

let obliterate aid = 
  let! () = ohm $ Pending.obliterate aid in 
  let! avatar = ohm_req_or (return ()) $ Tbl.get aid in 
  let! () = ohm $ Signals.on_obliterate_call (aid, avatar # ins) in 
  Tbl.delete aid 

let obliterate_for_user uid = 
  let! list = ohm $ avatars_of_user uid in 
  let! ()   = ohm $ Run.list_iter obliterate list in 
  return ()

let obliterate_for_user_later = 
  O.async # define "obliterate-user-avatars" IUser.fmt obliterate_for_user 

let _ =
  Sig.listen MUser.Signals.on_obliterate obliterate_for_user

(* Final submodules ----------------------------------------------------------------------- *)

module Backdoor = struct

  let user_instances = user_instances

  module AllView = CouchDB.MapView(struct
    module Key    = Fmt.Unit
    module Value  = Fmt.Make(struct
      type json t = (IUser.t * IInstance.t * Status.t)
    end)  
    module Design = Design
    let name = "backdoor-all"
    let map  = "if (doc.t == 'avtr') emit(null,[doc.who,doc.ins,doc.sta])" 
  end)

  let all = 
    let! list = ohm $ AllView.query () in
    return $ List.map (#value) list

  module CountView = CouchDB.ReduceView(struct
    module Key = Fmt.Unit
    module Value = Fmt.Int
    module Reduced = Fmt.Int
    module Design = Design
    let name   = "backdoor-count"
    let map    = "if (doc.t == 'avtr') emit(null,1);"
    let reduce = "return sum(values);"
    let group  = true
    let level  = None
  end)

  let count =
    Run.bind (fun () -> 
      CountView.reduce_query () |> Run.map begin function
	| ( _, v ) :: _ -> v 
	| _ -> 0
      end
    ) (return ()) 

  let list ~count start = 
    let! ids, next = ohm $ Tbl.all_ids ~count start in
    let! avatars = ohm $ Run.list_filter begin fun aid ->
      let! avatar = ohm_req_or (return None) $ Tbl.get aid in 
      return (Some (avatar # who, avatar # ins, avatar # sta))
    end ids in

    return (avatars, next)

  let refresh_grants = Async.Convenience.foreach O.async "refresh-grants"
    IAvatar.fmt (Tbl.all_ids ~count:50) Signals.refresh_grant_call

  let refresh_grants () = 
    refresh_grants () 

  let refresh_avatar_atoms = Async.Convenience.foreach O.async "refresh-avatar-atoms"
    IAvatar.fmt (Tbl.all_ids ~count:10) 
    (fun aid -> 
      let! avatar = ohm_req_or (return ()) $ Tbl.get aid in
      let! name   = req_or (return ()) (avatar # name) in
      let  iid    = avatar # ins in
      let  ()     = Util.log "Reflect avatar %s [%s > %s]" name 
	(IInstance.to_string iid) (IAvatar.to_string aid) in
      MAtom.reflect iid `Avatar (IAvatar.to_id aid) name)
   
  let refresh_avatar_atoms () = 
    refresh_avatar_atoms () 
 
end

