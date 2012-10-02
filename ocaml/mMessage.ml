(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

module MyDB = MModel.MessageDB
module MyUnique = OhmCouchUnique.Make(MyDB)

module Design = struct
  module Database = MyDB
  let name = "message"
end

module Delay = struct

  (* After sending an e-mail notice, wait 20 minutes before sending another. *)
  let after_send = 20. *. 60.

  (* When invited to a conversation, only mark it as unread if anything happened 
     in the last 15 days *)
  let archive_age = 3600. *. 24. *. 15.	  

end

module Envelope = struct

  module Data = Fmt.Make(struct
    module Float     = Fmt.Float
    module PAvatar   = IAvatar
    module PInstance = IInstance
    module PUser     = IUser
    type json t = <
      t               : MType.t ;
      title           : string ;
      last            : Float.t ;
      last_by  "lsby" : PAvatar.t ;
      prev_by  "prby" : PAvatar.t option ;
      people   "nppl" : int ;
      instance "ins"  : PInstance.t 
      > 
  end)

  module MyTable = CouchDB.Table(MyDB)(IMessage)(Data)

  include Data

  let get mid = 
    MyTable.get (IMessage.decay mid)
    
end

module Signals = struct

  let on_send_call, on_send = Sig.make (Run.list_iter identity)
    
end

let find_feed ~ctx mid =
  let mid = IMessage.decay mid in
  MFeed.get_for_message ctx mid 

let get_feed iid mid = 
  MFeed.bot_find iid (Some (`of_message (IMessage.decay mid))) 
    
module Subscription = struct

  module Data = Fmt.Make(struct
    module Float       = Fmt.Float
    module AccessState = MAccess.State
    type json t = <
      t               : MType.t ;
      who             : IUser.t ;
      avatar   "avtr" : IAvatar.t ;
      what            : IMessage.t ;
      read            : Float.t ;
      instance "ins"  : IInstance.t ;
      last            : Float.t ;
     ?tosend          : IItem.t list = [] ; 
     ?because         : [ `direct "d" 
			| `group  "g" of IGroup.t * AccessState.t ] list = [ `direct ] ;
      author          : bool
    >
  end)

  module MyTable = CouchDB.Table(MyDB)(Id)(Data)

  include Data

  let to_unique who what = 
    OhmCouchUnique.pair (IUser.to_id who) (IMessage.to_id what)

  let find who what = 
    MyUnique.get (to_unique who what)
    
  module DirectByEnvelopeView = CouchDB.MapView(struct
    module Key = IMessage
    module Value = IAvatar
    module Design = Design
    let name = "direct_by_envelope"
    let map  = "if (doc.t == 'msbs') {
                  var doEmit = false; 
                  if ('because' in doc) {
                    for (var k in doc.because) 
                      if (doc.because[k] == 'd') 
                        { doEmit = true; break; }
                  } else doEmit = true;
                  if (doEmit) emit(doc.what,doc.avtr)
                }" 
  end)

  let direct_by_envelope mid = 
    DirectByEnvelopeView.by_key (IMessage.decay mid)

  module ByAvatar = CouchDB.DocView(struct
    module Key    = IAvatar
    module Value  = Fmt.Unit
    module Doc    = Data
    module Design = Design
    let name = "by_avatar" 
    let map  = "if (doc.t == 'msbs') emit(doc.avtr,null);"
  end)

  let _ = 
    let obliterate sid = 
      let! sbs = ohm_req_or (return ()) $ MyTable.get sid in 
      let! ()  = ohm $ MyUnique.remove_atomic (to_unique (sbs # who) (sbs # what)) sid in
      let! _   = ohm $ MyTable.transaction sid MyTable.remove in
      return ()
    in
    let on_obliterate_avatar (aid,_) = 
      let! list = ohm $ ByAvatar.doc aid in
      let! _    = ohm $ Run.list_iter (#id |- obliterate) list in
      return ()
    in
    Sig.listen MAvatar.Signals.on_obliterate on_obliterate_avatar

  module AllByEnvelopeView = CouchDB.MapView(struct
    module Key = IMessage
    module Value = IAvatar
    module Design = Design
    let name = "all_by_envelope"
    let map  = "if (doc.t == 'msbs')
                  if (!('because' in doc) || doc.because.length > 0) 
                    emit(doc.what,doc.avtr)" 
  end)

  let all_by_envelope mid = 
    AllByEnvelopeView.by_key (IMessage.decay mid)

  module RefreshTaskArgs = Fmt.Make(struct
    type json t = IFeed.t * IMessage.t * IAvatar.t * IItem.t 
  end) 

  let _refresh_task =
    Task.register "message-subscription-refresh" RefreshTaskArgs.fmt
      begin fun (fid,mid,aid,iid) _ -> 
	
	let finished = return $ Task.Finished (fid,mid,aid,iid) in
	
	let! envelope      = ohm_req_or finished $ Envelope.get mid in
	let! subscriptions = ohm $ all_by_envelope mid in
	let! blockers      = ohm $ MBlock.all_blockers (`Feed fid) in
	
	let refresh_subscription item = 

	  let update sbs =
	    
	    let do_not_notify =
	      aid = sbs # avatar || (* do not notify self *)
	      BatPSet.mem sbs # avatar blockers (* do not notify blockers *)
	    in
	    
	    if not (List.mem iid (sbs # tosend)) then 
	      let last = max (sbs # last) (envelope # last) in 
	      (), `put (object
		method t        = `MessageSubscription
		method who      = sbs # who
		method what     = sbs # what
		method avatar   = sbs # avatar
		method instance = sbs # instance
		method last     = last 
		method author   = sbs # author
		method read     = if do_not_notify then last +. 1.0 else sbs # read
		method tosend   = if do_not_notify then sbs#tosend else iid :: (sbs#tosend)  
		method because  = sbs # because
	      end)
	    else (), `keep
	  in
	  
	  MyTable.transaction (item # id) (MyTable.if_exists update)
	    
	in
	
	let! _ = ohm $ Run.list_map refresh_subscription subscriptions in
	
	finished
	  
      end

  let refresh fid mid aid iid =     
    MModel.Task.call _refresh_task
      (fid,IMessage.decay mid,IAvatar.decay aid,IItem.decay iid) |> Run.map ignore

  let read who mid = 

    let! id = ohm $ find who mid in
    
    let update sbs = 
      if sbs # last > sbs # read then (), `put (object
	method t        = `MessageSubscription
	method last     = sbs # last
	method instance = sbs # instance
	method read     = Unix.gettimeofday ()
	method tosend   = []
	method who      = sbs # who
	method what     = sbs # what
	method author   = sbs # author
	method avatar   = sbs # avatar
	method because  = sbs # because
      end) else (), `keep
    in
    
    MyTable.transaction id (MyTable.if_exists update) |> Run.map ignore

  
  let _auto_remove because who mid = 
    let! id = ohm $ find who mid in

    let update d = 
      if not (List.mem because (d # because)) then (), `keep else
	if d # because = [because] then (), `delete else
	  (), `put (object	    
	    method t        = `MessageSubscription
	    method last     = d # last
	    method instance = d # instance
	    method who      = d # who
	    method what     = d # what
	    method read     = d # read
	    method tosend   = d # tosend
	    method author   = d # author
	    method avatar   = d # avatar
	    method because  = List.filter (fun x -> x <> because) (d # because)
	  end)
    in
    
    MyTable.transaction id (MyTable.if_exists update) |> Run.map ignore

  let _auto_create ?(is_author=false) because who avatar mid envelope = 
    
    let time = 
      if is_author then Unix.gettimeofday () +. 10.0 
      else Unix.gettimeofday () -. Delay.archive_age
    in

    let! id = ohm $ find who mid in

    let update id = 

      let! sbs = ohm $ MyTable.get id in 
      match sbs with 
	| None -> let! fid = ohm $ get_feed (envelope # instance) mid in
		  let! tosend = ohm begin
		    (* We can read the feed because we are currently being added
		       to the list of readers. *)
		    let  fid  = IFeed.Assert.read fid in 
		    let  self = IAvatar.Assert.is_self avatar in 
		    let! last = ohm_req_or (return []) $ MItem.last ~self (`feed fid) in
		    if last # own <> None then return [] else 
		      return [ IItem.decay (last # id) ]
		  end in
		  let o = object
		    method t        = `MessageSubscription
		    method last     = envelope # last
		    method instance = envelope # instance
		    method who      = IUser.decay who
		    method what     = mid
		    method read     = time
		    method tosend   = tosend
		    method author   = is_author
		    method avatar   = avatar
		    method because  = [because]
		  end in
		  return ((), `put o)
	| Some d -> let known = List.mem because (d # because) in
		    if known then return ((), `keep) else
		      let o = object
			method t        = `MessageSubscription
			method last     = d # last
			method instance = d # instance 
			method who      = d # who 
			method what     = d # what
			method read     = d # read
			method tosend   = d # tosend
			method author   = d # author
			method avatar   = d # avatar		  
			method because  = because :: d # because
		      end in
		      return ((), `put o)  
    in
    
    let! _ = ohm $ MyTable.transaction id update in
    return ()
      
  let _create ?(is_author=false) because avatar mid envelope = 
    let! details = ohm $ MAvatar.details avatar in
    if details # ins = Some (envelope # instance) then 
      let! who = req_or (return ()) (details # who) in
      _auto_create ~is_author because who avatar mid envelope
    else 
      return ()

  module CreateAll = Fmt.Make(struct
    module PAvatar  = IAvatar
    module PMessage = IMessage
    type json t = PMessage.t * (PAvatar.t list)
  end)
    
  let _create_task = 
    Task.register "message-subscription-createAll" CreateAll.fmt begin fun (mid,who) _ ->

      let! () = ohm begin 
	let! envelope = ohm_req_or (return ()) $ Envelope.get mid in
	let! ()       = ohm $ Run.list_iter
	  (fun who -> _create `direct who mid envelope) who
	in
	return ()
      end in

      return $ Task.Finished (mid,who)

    end

  module CreateGroupAll = Fmt.Make(struct
    module PAvatar     = IAvatar
    module PMessage    = IMessage
    module PGroup      = IGroup
    module AccessState = MAccess.State
    type json t = PMessage.t * PGroup.t * AccessState.t * (PAvatar.t list)
  end)

  let _create_group_task = 
    Task.register "message-subscription-createGroupAll" CreateGroupAll.fmt
      begin fun (mid,gid,access,who) _ ->
	
	let! () = ohm begin
	  let! envelope = ohm_req_or (return ()) $ Envelope.get mid in
	  let! ()       = ohm $ Run.list_iter
	    (fun who -> _create (`group (gid,access)) who mid envelope) who
	  in
	  return ()
	end in
	return $ Task.Finished (mid,gid,access,who)
      end

  let create_author mid envelope avatar = 
    _create ~is_author:true `direct avatar mid envelope

  let create_all mid envelope = function
    | []    -> return ()
    | [who] -> _create `direct who mid envelope 
    | list  -> MModel.Task.call _create_task (mid,list) |> Run.map ignore

  let create_all_delayed mid = function
    | []   -> return ()
    | list -> MModel.Task.call _create_task (mid,list) |> Run.map ignore

  let create_group_delayed mid gid access = function
    | []   -> return ()
    | list -> MModel.Task.call _create_group_task (mid,IGroup.decay gid,access,list) 
              |> Run.map ignore

  module UnsentView = CouchDB.DocView(struct
    module Key = Fmt.Float
    module Value = Fmt.Unit
    module Doc = Data
    module Design = Design
    let name = "unsent"
    let map  = "if (doc.t == 'msbs' && doc.tosend && doc.tosend.length > 0) 
                  emit(doc.last,null);" 
  end)

  let next_unsent = 
    let! list = ohm $ UnsentView.doc_query  ~startkey:0.0 ~limit:1 () in
    match list with 
      | []        -> return None
      | item :: _ -> match item # doc # tosend with 
	  | []       -> return None
	  | iid :: _ -> return $ Some (item # id, item # doc, iid)

  let sent sid iid = 
    let update sbs = 
      if List.mem iid (sbs # tosend) then (), `put (object
	method t        = `MessageSubscription
	method last     = sbs # last
	method instance = sbs # instance
	method who      = sbs # who
	method what     = sbs # what
	method read     = sbs # read
	method tosend   = BatList.remove (sbs # tosend) iid
	method author   = sbs # author
	method avatar   = sbs # avatar
	method because  = sbs # because
      end) else (), `keep
    in
    
    MyTable.transaction sid (MyTable.if_exists update) |> Run.map ignore
	
  module ParticipantCount = Fmt.Make(struct
    type json t = <
      count "c" : int ;
      some  "s" : IAvatar.t list
    >
  end)

  module CountView = CouchDB.ReduceView(struct
    module Key = IMessage
    module Value = ParticipantCount
    module Reduced = ParticipantCount
    module Design = Design 
    let name   = "participants" 
    let map    = "if (doc.t == 'msbs') emit(doc.what,{c:1,s:[doc.avtr]})" 
    let group  = true 
    let level  = None 
    let reduce = "var r = {c:0,s:[]};
                  for (var k in values) { r.c += values[k].c ; r.s = r.s.concat(values[k].s); }
                  if (r.s.length > 2) r.s.length = 2;
                  return r;" 
  end)

  let count mid = 
    let mid = IMessage.decay mid in 
    let! count_opt = ohm $ CountView.reduce mid in
    match count_opt with 
      | Some count -> return count
      | None       -> return 
	(object
	  method count = 0
	  method some  = []
	 end)
	
end

module GroupSend = struct

  module Data = Fmt.Make(struct
    module PGroup = IGroup
    module PMessage = IMessage
    module AccessState = MAccess.State
    type json t = <
      t              : MType.t ;
      what           : PMessage.t ;
      group          : PGroup.t ;
      access         : AccessState.t
    >
  end)

  module MyTable = CouchDB.Table(MyDB)(Id)(Data)

  include Data

  let to_unique group access what = 
    OhmCouchUnique.pair (IGroup.to_id group) (IMessage.to_id what)
    ^ (match access with 
      | `Pending -> "-p"
      | `Any -> "-a"
      | `Validated -> "")

  let find group access what = 
    MyUnique.get (to_unique group access what)

  module ByEnvelopeView = CouchDB.DocView(struct
    module Key   = IMessage
    module Value = Fmt.Unit      
    module Doc   = Data
    module Design = Design
    let name = "groups_by_envelope" 
    let map  = "if (doc.t == 'gmsg') emit(doc.what,null)" 
  end)

  let by_envelope mid = 
    let! list = ohm $ ByEnvelopeView.doc (IMessage.decay mid) in
    return $ List.map
      (fun item -> let d = item # doc in d # group , d # access) list

  module ByGroupView = CouchDB.DocView(struct
    module Key = IGroup
    module Value = Fmt.Unit
    module Doc = Data
    module Design = Design
    let name = "by_group"
    let map  = "if (doc.t == 'gmsg') emit(doc.group,null)" 
  end)

  let by_group gid = 
    let! list = ohm $ ByGroupView.doc (IGroup.decay gid) in
    return $ List.map (#doc) list

  let update_group gid aid add =
    let! all     = ohm $ by_group gid in
    let! details = ohm $ MAvatar.details aid in
    let! who     = req_or (return ()) (details # who) in
    
    let update_sbs sbs = 
      let  because  = `group (sbs # group, sbs # access) in
      let! envelope = ohm_req_or (return ()) $ Envelope.get (sbs # what) in
      
      if add (sbs # access) then 
	Subscription._auto_create because who aid (sbs # what) envelope
      else
	Subscription._auto_remove because who (sbs # what)
    in
    
    let! () = ohm $ Run.list_iter update_sbs all in
    
    return ()
      
  let _ = 
    let update (mid,membership) = 
      let gid, aid, status = MMembership.(
	membership.where, 
	membership.who,
	membership.status
      ) in
      let add = match status with 
	| `NotMember | `Declined -> (fun _ -> false)
	| `Invited | `Pending | `Unpaid -> (function `Validated -> false | _ -> true)
	| `Member -> (fun _ -> true)
      in
      update_group gid aid add
    in
    Sig.listen MMembership.Signals.after_update update
   
  let add group access what =     
    let! id = ohm $ MyUnique.get (to_unique group access what) in
    
    let update = function
      | None -> true, `put (object
	method t      = `GroupMessage
	method group  = IGroup.decay group
	method what   = IMessage.decay what
	method access = access
      end)
      | Some o -> false, `keep 
    in

    let! created = ohm $ MyTable.transaction id (fun i -> MyTable.get i |> Run.map update) in
    
    if created then 
      let! people = ohm $ MMembership.InGroup.all group access in
      let! () = ohm $ Subscription.create_group_delayed
	what group access (List.map snd people) 
      in
      return ()
    else
      return ()

end

let send_next = 
  let! sid, sbs, iid = ohm_req_or (return false) $ Subscription.next_unsent in
  let! () = ohm $ Signals.on_send_call
    (sbs # who, sbs # read, sbs # what, iid) 
  in
  let! () = ohm $ Subscription.sent sid iid in 
  return true
  
let _ = Ohm.Task.Background.register 1 send_next

module ItemAddRefreshInfo = Fmt.Make(struct
  module Float    = Fmt.Float
  type json t = IFeed.t * IMessage.t * IAvatar.t * Float.t * IItem.t
end)
 
let _item_add_refresh_task = 
  Task.register "message-item_add_refresh" ItemAddRefreshInfo.fmt
    begin fun (fid,mid,who,time,iid) _ -> 
    
      let update envelope = 
	if envelope # last < time then (), `put (object
	  method t        = `Message
	  method last     = time
	  method last_by  = who
	  method prev_by  = 
	    if envelope # last_by <> who
	    then Some (envelope # last_by)
	    else envelope # prev_by
	  method people   = envelope # people
	  method instance = envelope # instance
	  method title    = envelope # title
	end) else (), `keep
      in
      
      let! _ = ohm $ Envelope.MyTable.transaction
	(IMessage.decay mid) (Envelope.MyTable.if_exists update)
      in

      let! () = ohm $ Subscription.refresh fid mid who iid in 

      return $ Task.Finished (fid,mid,who,time,iid)

  end

let item_add_refresh fid mid who iid = 
  let! _ = ohm $ MModel.Task.call _item_add_refresh_task 
    (IFeed.decay fid, IMessage.decay mid, IAvatar.decay who, Unix.gettimeofday (), iid)
  in
  return ()

let _user_refresh_task = 
  Task.register "message-user_refresh" IMessage.fmt begin fun mid _ ->
    let! stats = ohm $ Subscription.count mid in
    
    let update envelope = 
      let o = object
	method t        = `Message
	method last     = envelope # last
	method last_by  = envelope # last_by 
	method prev_by  =
	  if envelope # prev_by = None 
	  then try Some (List.find (fun aid -> aid <> envelope # last_by) (stats # some))
	    with Not_found -> None 
	  else envelope # prev_by 
	method people   = stats # count
	method instance = envelope # instance
	method title    = envelope # title
      end in
      if o # people <> envelope # people || o # prev_by <> envelope # prev_by then
	(), `put o
      else
	(), `keep
    in      

    let! _ = ohm $ Envelope.MyTable.transaction
      (IMessage.decay mid) (Envelope.MyTable.if_exists update) 
    in
    
    return $ Task.Finished mid
      
  end 

let user_refresh mid = 
  MModel.Task.call _user_refresh_task (IMessage.decay mid) |> Run.map ignore

let create ~instance ~who ~invited ~title = 
  let who    = IAvatar.decay who in
  let id     = Id.gen () in
  let mid    = IMessage.of_id id in 

  let o = object
    method t        = `Message
    method last     = Unix.gettimeofday ()
    method last_by  = who
    method prev_by  = None
    method people   = 1
    method instance = instance
    method title    = title
  end in

  let! envelope = ohm $ Envelope.MyTable.transaction mid (Envelope.MyTable.insert o) in
  let! ()       = ohm $ Subscription.create_author mid envelope who in 
  let! ()       = ohm $ Subscription.create_all    mid envelope invited in
  let! ()       = ohm (if invited <> [] then user_refresh mid else return ()) in
  
  return mid
  

let invite ~ctx ~invited mid = 
  let mid = IMessage.decay mid in 
  let! ok = ohm $ MAccess.test ctx [`Message mid] in
  if ok && invited <> [] then
    let! () = ohm $ Subscription.create_all_delayed mid invited in
    let! () = ohm $ user_refresh mid in
    return ()
  else
    return ()


let invite_group ~ctx ~invited ~access mid = 
  let mid = IMessage.decay mid in 
  let! ok = ohm $ MAccess.test ctx [`Message mid] in
  if ok then 
    GroupSend.add invited access mid 
  else
    return () 
      
let get_instance mid = 
  let mid = IMessage.decay mid in
  Envelope.MyTable.get mid |> Run.map (BatOption.map (fun e -> e # instance))

let create_and_post ~ctx ~invited ~title ~post = 
  
  let instance = ctx # isin |> IIsIn.instance |> IInstance.decay in
  
  let! who = ohm (ctx # self) in 
    
  let! mid = ohm begin 
    create
      ~instance
      ~who
      ~title
      ~invited
  end in 
  
  let! feed = ohm $ find_feed ~ctx mid in

  (* We can write to the feed we just created. *)
  let  feed = IFeed.Assert.write (MFeed.Get.id feed) in
   
  let! _ = ohm $ MItem.Create.message who post instance feed in

  return mid
	  
let get_title ~ctx mid =  
  let mid = IMessage.decay mid in
  let! ok = ohm $ MAccess.test ctx [`Message mid] in
  if ok then 
    let! envelope = ohm_req_or (return `None) $
      Envelope.MyTable.get (IMessage.decay mid)
    in
    return $ `Some (envelope # title)
  else return `Forbidden

let get_participants ~ctx mid = 
  let mid = IMessage.decay mid in 
  let! ok = ohm $ MAccess.test ctx [`Message mid] in
  if ok then 
    let! sbslist = ohm $ Subscription.direct_by_envelope mid in 
    return $ `List (List.map (#value) sbslist)
  else return `Forbidden 

let get_participants_forced iid mid = 
  let! participants = ohm $ Subscription.direct_by_envelope mid in
  let! groups       = ohm $ GroupSend.by_envelope mid in
  return (List.map (#value) participants, groups)

let get_groups ~ctx mid = 
  let mid = IMessage.decay mid in 
  let! ok = ohm $ MAccess.test ctx [`Message mid] in
  if ok then 
    let! list = ohm $ GroupSend.by_envelope mid in
    return $ `List list
  else return `Forbidden 
	
let in_message avatar message = 
  let! details = ohm $ MAvatar.details avatar in
  let! user    = req_or (return false) (details # who) in
  let! sbsopt  = ohm $ MyUnique.get_if_exists (Subscription.to_unique user message) in
  return $ BatOption.is_some sbsopt
  
let mark_as_read uid mid = 
  Subscription.read uid mid  

module ByInstanceKey = Fmt.Make(struct
  module PUser     = IUser
  module PInstance = IInstance
  type json t = PUser.t * PInstance.t
end)

module CountView = CouchDB.ReduceView(struct
  module Key = ByInstanceKey
  module Value = Fmt.Int
  module Reduced = Fmt.Int
  module Design = Design
  let name   = "count"
  let map    = "if (doc.t == 'msbs') if (doc.read < doc.last) emit([doc.who,doc.ins],1)"
  let group  = true
  let level  = None
  let reduce = "return sum(values);" 
end)

let count user =
  let uid = IUser.decay user in
  let! list = ohm $ CountView.reduce_query 
    ~startkey:(uid, IInstance.of_id Id.smallest) 
    ~endkey:(uid, IInstance.of_id Id.largest)
    ~endinclusive:true
    ()
  in
  return $ List.map (fun ((_,ins),count) -> (ins,count)) list

let total_count user = 
  let! unread = ohm $ count user in 
  return $ List.fold_left (fun acc (_,count) -> acc + count) 0 unread

module ByInstanceTimeKey = Fmt.Make(struct
  module PUser     = IUser
  module PInstance = IInstance
  module Float     = Fmt.Float
  let name = "Message.ByInstanceTimeKey" 
  type json t = PUser.t * PInstance.t * Float.t
end)

module ShortDetails = Fmt.Make(struct
  module PMessage = IMessage
  let name = "Message.ShortDetails.t"
  type json t = <
    id   "_id" : PMessage.t ;
    read       : bool
  >
end)

type message_details = <
  id       : [`Read] IMessage.id ;
  read     : bool ;
  title    : string ;
  last     : float ;
  last_by  : IAvatar.t ;  
  prev_by  : IAvatar.t option ;
  people   : int ;
  instance : IInstance.t
>

module GetByInstanceView = CouchDB.DocView(struct
  module Key = ByInstanceTimeKey 
  module Value = ShortDetails
  module Doc = Envelope
  module Design = Design
  let name = "by_instance"
  let map  = "if (doc.t == 'msbs') emit( [doc.who,doc.ins,doc.last],
                                         {_id:doc.what,read:doc.read > doc.last} );" 
end)

let get_by_instance ?before user instance count = 

  let  uid    = IUser.decay user in
  let  iid    = IInstance.decay instance in 
  let  before = match before with None -> Unix.gettimeofday () | Some before -> before in

  let! list = ohm $ GetByInstanceView.doc_query
    ~startkey:(uid,iid,before)
    ~endkey:(uid,iid,0.0)
    ~descending:true
    ~endinclusive:true
    ~limit:count
    ()
  in

  let details_of_item item = 
    let v = item # value and d = item # doc in 
    ( object
      (* It's in our feed : we can read it *)
      method id       = IMessage.Assert.read (v # id)
      method read     = v # read
      method title    = d # title
      method last     = d # last
      method last_by  = d # last_by
      method prev_by  = d # prev_by
      method people   = d # people
      method instance = d # instance
      end )
  in

  return $ List.map details_of_item list 

let _ = 
  let on_create item =
    let refresh_feed = function
      | `album _ 
      | `folder _ -> return () 
      | `feed fid -> 
	let  fid   = IFeed.Assert.bot fid in (* Acting as bot to propagate items *)
	let! feed  = ohm_req_or (return ()) $ MFeed.bot_get fid in 
	let  itid  = IItem.decay (item # id) in 
	let! who   = req_or (return ()) $ MItem.author (item # payload) in
	match MFeed.Get.owner feed with
	  | `of_message mid -> item_add_refresh fid mid who itid
	  |  _              -> return ()
	  
    in
    let! _ = ohm $ refresh_feed (item # where) in
    return ()
  in
  Sig.listen MItem.Signals.on_post on_create

let bot_get_details mid = 
  let details envelope = object
    method id       = IMessage.Assert.read mid
    method read     = false
    method title    = envelope # title
    method last     = envelope # last
    method last_by  = envelope # last_by
    method prev_by  = envelope # prev_by
    method people   = envelope # people
    method instance = envelope # instance
  end in

  Envelope.MyTable.get (IMessage.decay mid)
  |> Run.map (BatOption.map details)

