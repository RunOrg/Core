(* © 2012 MRunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

(* Including submodules ------------------------------------------------------------------- *)

module Common  = MAvatar_common
module Status  = MAvatar_status
module Signals = MAvatar_signals
module Pending = MAvatar_pending
module Details = MAvatar_details

(* Data types & formats ------------------------------------------------------------------- *)

module MyDB      = Common.MyDB
module MyTable   = Common.MyTable
module Design    = Common.Design

include Common.Data

module InsSta = Fmt.Make(struct
  type json t = IInstance.t * Status.t
end) 

module UsrSta = Fmt.Make(struct
  type json t = IUser.t * Status.t
end) 

module InsUsr = Fmt.Make(struct
  type json t = IInstance.t * IUser.t
end)

module Search = Fmt.Make(struct
  type json t = IInstance.t * string
end)

(* Refresh avatar cached data ------------------------------------------------------------- *)

let email_username email = 
  try let index = BatString.find email "@" in
      let prefix = BatString.head email (index+1) in
      prefix ^ "..."
  with Not_found -> email 

let data_from ~lastname ~firstname ~email ~picture = 
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

let data_from_profile details = 
  MProfile.Data.(
    data_from 
      ~lastname:details.lastname
      ~firstname:details.firstname
      ~email:details.email
      ~picture:details.picture 
  )

let self_data isin =
  let default = object 
    method name    = None
    method picture = None
    method role    = None
    method sort    = []
  end in
  let! profile = ohm $ MProfile.find_self isin in
  let! details = ohm $ MProfile.details profile in 
  match details with  
    | None         -> return default
    | Some details -> return $ data_from 
      ~lastname:(details # lastname)
      ~firstname:(details # firstname)
      ~email:(details # email)
      ~picture:(details # picture)
      
let refresh isin = 
  
  let avatar = IIsIn.avatar isin in
  let update = function 
    | None -> return ( (), `keep )
    | Some avatar -> 
      self_data isin |> Run.map begin fun data ->
	if 
	  data # name <> avatar # name 
	  || data # picture <> avatar # picture
	  || data # sort <> avatar # sort
	  || data # role <> avatar # role
	then 	
	  (), `put (object
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
	  (), `keep
      end
  in

  match avatar with 
    | None -> return ()
    | Some avatar -> let avatar = IAvatar.decay avatar in 
		     let! () = ohm $ MyTable.transaction avatar 
		       (fun i -> MyTable.get i |> Run.bind update)
		     in
		     Signals.on_update_call (avatar, IInstance.decay $ IIsIn.instance isin)
	
(* Details : extracted from the database when looking for details about an avatar --------- *)

include Details

(* Extraction ----------------------------------------------------------------------------- *)

let exists aid = 
  let  aid    = IAvatar.decay aid in 
  let! avatar = ohm $ MyTable.get aid in 
  return (avatar <> None)

module RelationView = CouchDB.DocView(struct
  module Key    = InsUsr
  module Value  = Status
  module Doc    = Common.Data
  module Design = Design
  let name = "relation"
  let map  = "if (doc.t == 'avtr') emit([doc.ins,doc.who],doc.sta)"
end)

let _get ins usr = 
  RelationView.doc (ins,usr) |> Run.map Util.first 

let _getid ins usr =
  _get ins usr |> Run.map (BatOption.map (#id |- IAvatar.of_id))

(* Status updates ------------------------------------------------------------------------- *)

let _update_status status ins usr =

  let ins = IInstance.decay ins in
  let usr = IUser.decay usr in
  
  let! aid = ohm $ _getid ins usr in
  let  aid = BatOption.default (IAvatar.gen ()) aid in
  
  let isin newsta = 
    let role = (newsta :> [`Admin|`Token|`Contact|`Nobody]) in
    (* 3x assert : We're building this one right now, let him fetch his own data *)
    let  aid = IAvatar.Assert.is_self aid in
    let  usr = IUser.Assert.is_old usr in
    let! instance = ohm $ MInstance.get ins in 
    let  light    = BatOption.default false (BatOption.map (#light) instance) in
    let  trial    = BatOption.default false (BatOption.map (#trial) instance) in
    match 
      IIsIn.Assert.make ~id:(Some aid) ~role ~ins ~light ~trial ~usr 
      |> IIsIn.Deduce.is_contact
    with None -> assert false | Some isin -> return isin 
  in

  let update = function
    | None -> 
      let  newsta = status None in 
      let! isin   = ohm $ isin newsta in 
      let! data   = ohm $ self_data isin in
      let! _      = ohm $ Pending.invite ~uid:usr ~iid:ins aid in
      return ((isin, true), `put (object
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
      let! isin   = ohm $ isin newsta in
      return (
	if obj # sta = newsta
	then (isin,false), `keep 
	else (isin,true), `put (object	
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
  
  let! isin, changed = ohm $ 
    MyTable.transaction aid (fun i -> MyTable.get i |> Run.bind update)
  in

  let! () = ohm $ Signals.on_update_call (aid, IInstance.decay $ IIsIn.instance isin) in
  
  return (aid, isin, changed)
				       
let _update_avatar_status status ?ins avatar =

  let avatar = IAvatar.decay avatar in
  let update obj = 
    let newsta = status (obj # sta) in
    if obj # sta = newsta || ins <> None && Some (obj # ins) <> ins
    then None, `keep 
    else Some (obj # ins), `put (object	
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
  
  let! result = ohm $ MyTable.transaction avatar (MyTable.if_exists update) in
  let! () = ohm begin 
    match result with 
      | None       
      | Some  None      -> return () 
      | Some (Some iid) -> Signals.on_update_call (avatar, iid)
  end in
  return $ BatOption.default None result

let eventful_upgrade how signal ?from avatar =
  let! iid = ohm_req_or (return ()) $ _update_avatar_status how avatar in
  signal (from, IAvatar.decay avatar, iid)

let upgrade_to_admin = eventful_upgrade
  (fun _ -> `Admin) Signals.on_upgrade_to_admin_call

let upgrade_to_member = eventful_upgrade 
  (function `Admin -> `Admin | _ -> `Token) Signals.on_upgrade_to_member_call

let downgrade_to_contact = eventful_upgrade
  (fun _ -> `Contact) Signals.on_downgrade_to_contact_call

let downgrade_to_member = eventful_upgrade 
  (function `Contact -> `Contact | _ -> `Token) Signals.on_downgrade_to_member_call

let change_to_member ?from avatar = 
  let! current = ohm_req_or (return ()) $ MyTable.get (IAvatar.decay avatar) in
  match current # sta with 
    | `Admin   -> downgrade_to_member ?from avatar
    | `Contact
    | `Token   -> upgrade_to_member ?from avatar

let become_contact instance user = 
  let! id, _, _ = ohm $
    _update_status (function 
      | Some `Admin -> `Admin
      | Some `Token -> `Token
      | _ -> `Contact) instance user 
  in
  return id

let become_admin instance user =
  let! _, isin, _ = ohm $ _update_status (fun _ -> `Admin) instance user in
  return (IIsIn.Deduce.is_admin isin)

(* Identify an user for an instance ------------------------------------------------------- *)

let status iid cuid = 
  let  uid = IUser.Deduce.is_anyone cuid in
  let  iid = IInstance.decay iid in 
  let! result = ohm_req_or (return `Contact) $ _get iid uid in
  match result # value with 
    | `Admin -> return `Admin
    | `Contact | `Nobody -> return `Contact
    | `Token -> return `Token

let do_identify_user instance user cuid = 
  let  usr = IUser.decay     user     in
  let  ins = IInstance.decay instance in 
  let! result = ohm $ _get ins usr in
        
  let! inst = ohm $ MInstance.get ins in 
  let  light    = BatOption.default false (BatOption.map (#light) inst) in
  let  trial    = BatOption.default false (BatOption.map (#trial) inst) in
  
  let id, role = match result with 
    | None      -> None,    `Nobody
    | Some item -> Some (item # id), (item # value :> [`Admin|`Contact|`Token|`Nobody])
  in

  let id = id
    |> BatOption.map IAvatar.of_id
      (* The database said so... *)
    |> BatOption.map IAvatar.Assert.is_self 
  in
  
  (* The database said so... *)
  return $ IIsIn.Assert.make ~id ~role ~ins:instance ~light ~trial ~usr:cuid
 
let identify_user instance user = 
  do_identify_user instance user (IUser.Deduce.self_is_current user)

let identify_bot instance user = 
  do_identify_user instance user (IUser.Deduce.self_is_current user)
    
let identify instance cuid = 
  do_identify_user instance (IUser.decay (IUser.Deduce.current_is_self cuid)) cuid

let identify_avatar id = 
  let! avatar = ohm_req_or (return None) $ MyTable.get (IAvatar.decay id) in

  (* There's an avatar, so we are a contact *)
  let ins  = IInstance.Assert.is_contact avatar # ins in 
  let role = (avatar # sta :> [`Admin|`Contact|`Token|`Nobody]) in
  let usr  = IUser.Assert.is_old (avatar # who) in 
  
  let! instance = ohm $ MInstance.get ins in 
  let  light    = BatOption.default false (BatOption.map (#light) instance) in
  let  trial    = BatOption.default false (BatOption.map (#trial) instance) in

  (* The database said so *)
  return $ Some (IIsIn.Assert.make ~id:(Some id) ~role ~ins ~light ~trial ~usr)

let profile aid = 
  let  selfsame = IProfile.of_string (IAvatar.to_string aid) in
  let! a        = ohm_req_or (return selfsame) $ MyTable.get (IAvatar.decay aid) in
  let! pid      = ohm_req_or (return selfsame) $ MProfile.find (a#ins) (a#who) in
  return pid 

(* Count members with a token ------------------------------------------------------------- *)

module CountMembersView = CouchDB.ReduceView(struct
  module Key = IInstance
  module Value = Fmt.Int
  module Reduced = Fmt.Int
  module Design = Design
  let name   = "usage" 
  let map    = "if (doc.t == 'avtr' && (doc.sta == 'mbr' || doc.sta == 'own')) emit(doc.ins,1)" 
  let reduce = "return sum(values)"
  let level  = None
  let group  = true
end)

let usage iid =
  let iid = IInstance.decay iid in 
  CountMembersView.reduce iid |> Run.map (BatOption.default 0)

(* List all members of an instance -------------------------------------------------------- *)

module MembersView = CouchDB.DocView(struct
  module Key = Fmt.Make(struct
    module IInstance = IInstance
    type json t = IInstance.t * string
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
    module IInstance = IInstance
    type json t = IInstance.t * string
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
    module IInstance = IInstance
    type json t = IInstance.t * string
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

(* Extraction ----------------------------------------------------------------------------- *)

let get isin = 
  match IIsIn.avatar isin with 
    | Some avatar -> return avatar
    | None        -> let  instance = IIsIn.instance isin in
		     let  cuid     = IIsIn.user isin in
		     let! aid      = ohm $
		       become_contact instance (IUser.Deduce.is_anyone cuid)
		     in
		     (* Reconstructed an avatar from scratch, but that's still me! *)
		     return $ IAvatar.Assert.is_self aid

(* MUser instances ------------------------------------------------------------------------- *)

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
  module Doc    = Common.Data
  module Design = Design
  let name = "by_status" 
  let map  = "if (doc.t == 'avtr') {
                switch (doc.sta) {
                  case 'own': emit([doc.ins,'own'],null); 
                  case 'mbr': emit([doc.ins,'mbr'],null);
                  case 'ctc': emit([doc.ins,'ctc'],null);
                  default: return;
                }
              }" 
end)

let by_status iid status = 
  let! list = ohm $ ByStatusView.by_key (IInstance.decay iid, status) in
  return $ List.map (fun item -> IAvatar.of_id item # id) list

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

  let! _, user, instance, data = Sig.listen MProfile.Signals.on_update in 
  let! id = ohm_req_or (return ()) $ _getid instance user in
  
  let update avatar = 
    let data = data_from_profile data in
    if 
      data # name <> avatar # name 
      || data # picture <> avatar # picture
      || data # sort <> avatar # sort
      || data # role <> avatar # role
    then 	
      (), `put (object
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
      (), `keep
  in
  
  let! _ = ohm $ MyTable.transaction id (MyTable.if_exists update) in
  Signals.on_update_call (id,instance)

(* Obliterate all avatars for an user ----------------------------------------------------- *)

let avatars_of_user uid = 
  let! list = ohm $ ByUserView.query ~startkey:(uid,`Contact) ~endkey:(uid,`Admin) () in
  return $ List.map (#id |- IAvatar.of_id) list

let obliterate aid = 
  let! () = ohm $ Pending.obliterate aid in 
  let! avatar = ohm_req_or (return ()) $ MyTable.get aid in 
  let! () = ohm $ Signals.on_obliterate_call (aid, avatar # ins) in 
  let! _  = ohm $ MyTable.transaction aid MyTable.remove in 
  return () 

let obliterate_for_user uid = 
  let! list = ohm $ avatars_of_user uid in 
  let! ()   = ohm $ Run.list_iter obliterate list in 
  return ()

let obliterate_for_user_later = 
  let task = O.async # define "obliterate-user-avatars" IUser.fmt obliterate_for_user in
  fun uid -> task uid

let _ =
  Sig.listen MUser.Signals.on_obliterate obliterate_for_user

(* Propagate avatar merge signal. --------------------------------------------------------- *)

let avatar_instances_of_user uid = 
  let! list = ohm $ ByUserView.query ~startkey:(uid,`Contact) ~endkey:(uid,`Admin) () in
  return $ List.map (fun item -> IAvatar.of_id item # id, item # value) list 

let _ = 
  let on_user_merge (merged_uid, into_uid) = 
    let! merged_avatars = ohm $ avatar_instances_of_user merged_uid in
    let! () = ohm $ Run.list_iter begin fun (merged_aid,iid) ->
      let! into_aid   = ohm $ become_contact iid into_uid in 
      let! ()         = ohm $ Signals.on_merge_call (merged_aid, into_aid) in
      return () 
    end merged_avatars in
    let! _ = ohm $ obliterate_for_user_later merged_uid in
    return ()
  in
  Sig.listen MUser.Signals.on_merge on_user_merge

(* Final submodules ----------------------------------------------------------------------- *)

module Backdoor = struct

  let user_instances = user_instances

  module AllView = CouchDB.MapView(struct
    module Key    = Fmt.Unit
    module Value  = Fmt.Make(struct
      type json t = IUser.t * IInstance.t * Status.t
    end)  
    module Design = Design
    let name = "backdoor-all"
    let map  = "if (doc.t == 'avtr') emit(null,[doc.who,doc.ins,doc.sta])" 
  end)

  let all = 
    let! list = ohm $ AllView.query () in
    return $ List.map (#value) list

end

module List    = MAvatar_list
