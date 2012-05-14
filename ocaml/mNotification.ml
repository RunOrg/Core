(* © 2012 MRunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

module Float     = Fmt.Float

module MyDB     = CouchDB.Convenience.Database(struct let db = O.db "notify" end)
module MyUnique = OhmCouchUnique.Make(MyDB)
module Design = struct
  module Database = MyDB
  let name = "notify"
end

(* Data type definitions ------------------------------------------------------------------- *)

module ChannelType = MUser.Notification

module Channel = struct 
  include Fmt.Make(struct
      type json t = [ `myMembership   "mm"
		    | `likeItem       "li" of IItem.t
		    | `commentItem    "ci" of IItem.t
		    | `publishItem    "i"  of IItem.t
		    | `welcome        "w" 
		    | `joinEntity     "j"  of IEntity.t * MEntityKind.t
		    | `joinPending    "jp" of IEntity.t
		    | `networkInvite  "n"  of IRelatedInstance.t
		    | `networkConnect "c"  of IRelatedInstance.t
		    | `chatReq        "cr" of [ `entity   "e" of IEntity.t 
					      | `instance "i" of IInstance.t ]
		    ]
  end)

  let to_type : t -> ChannelType.t = function
    | `myMembership  -> `myMembership
    | `likeItem    _ -> `likeItem
    | `commentItem _ -> `commentItem
    | `welcome       -> `welcome
    | `publishItem _ -> `item

    | `joinEntity (_,`Subscription) -> `subscription
    | `joinEntity (_,`Event)        -> `event
    | `joinEntity (_,`Forum)        -> `forum
    | `joinEntity (_,`Album)        -> `album
    | `joinEntity (_,`Group)        -> `group
    | `joinEntity (_,`Poll)         -> `poll
    | `joinEntity (_,`Course)       -> `course

    | `joinPending _ -> `pending

    | `networkConnect _ 
    | `networkInvite  _ -> `networkInvite

    | `chatReq        _ -> `chatReq

  let unique instance channel user = 
    String.concat "-" begin
      (match instance with Some iid -> [ IInstance.to_string iid ] | None -> [])
      @ [ IUser.to_string user ]
      @ (match channel with 
	| `myMembership      -> ["mm"]
	| `publishItem    i  -> ["i"  ; IItem.to_string i]
	| `likeItem       i  -> ["li" ; IItem.to_string i]
	| `commentItem    i  -> ["ci" ; IItem.to_string i]
	| `welcome           -> ["w"]	
	| `joinEntity  (e,_) -> ["j" ; IEntity.to_string e]
	| `joinPending    e  -> ["jp" ; IEntity.to_string e ]
	| `networkInvite  i  -> ["n" ; IRelatedInstance.to_string i ]
	| `networkConnect i  -> ["c" ; IRelatedInstance.to_string i ]
	| `chatReq (`instance i) -> [ "cr" ; IInstance.to_string i ]
	| `chatReq (`entity   e) -> [ "cr" ; IEntity.to_string e ] 
      )
    end
end

let type_of_channel = Channel.to_type

module JoinPending = struct

  include Fmt.Make(struct
    type json t = <
      who  : IAvatar.t ;
      what : IEntity.t 
    > 
  end) 

  let who t = t # who
  let what t = t # what

  let make what who = 
    Some (`joinPending (object
      method what = what
      method who = who
    end : t))

  let equal a b = (a # who = b # who) && (a # what = b # what)

end

module MyMembership = struct

  include Fmt.Make(struct
    type json t = < 
      who : IAvatar.t ; 
      what : [ `toAdmin    "a"
	     | `toMember   "m" ]
    >
  end)

  let who t = t # who

  let make who state = 
    Some (`myMembership (object
      method who  = who
      method what = state
    end : t)) 

  let equal a b = ( a # who = b # who ) && (a # what = b # what) 
end

module PublishItem = struct
  include Fmt.Make(struct
    type json t = <
      who  : IAvatar.t ;
      what : IItem.t
    >
  end)

  let who t = Some (t # who)

  let make who what = Some (`publishItem (object
    method who  = who
    method what = what 
  end : t))

  let equal a b = (a # who = b # who) && (a # what = b # what) 

end

module LikeItem = struct

  include Fmt.Make(struct
    type json t = < 
      who : IAvatar.t ; 
      on  : IItem.t 
    >
  end)

  let who t = Some (t # who)

  let make who on = Some (`likeItem (object
    method who = who
    method on  = on
  end : t)) 

  let equal a b = ( a # who = b # who ) && ( a # on = b # on )

end

module CommentItem = struct

  include Fmt.Make(struct
    type json t = < 
      who  : IAvatar.t ;
      on   : IItem.t ; 
      what : IComment.t 
    >
  end) 

  let who t = Some (t # who)

  let make who on what = Some (`commentItem (object
    method who  = who
    method on   = on
    method what = what
  end : t))

  let equal a b = (a # who = b # who) && (a # on = b # on) && (a # what = b # what)
    
end

module JoinEntity = struct

  include Fmt.Make(struct
    type json t = <
      who  : IAvatar.t ;
      what : IEntity.t ;
      kind : MEntityKind.t ;
      how  : [ `invite ]
    >
  end)

  let invite who what kind = Some (`joinEntity (object
    method who  = who
    method what = what
    method kind = kind
    method how  = `invite
  end))

  let equal a b = 
    (a # who = b # who) && (a # what = b # what) && (a # kind = b # kind) && (a # how = b # how)

end

module NetworkInvite = struct

  include Fmt.Make(struct
    type json t = <
      who       : IAvatar.t ;
      text      : string ;
      contact   : IRelatedInstance.t ;
     ?contacted : string = "" 
    >
  end)

  let invite who text contact contacted = Some (`networkInvite (object
    method who       = who
    method text      = text
    method contact   = contact
    method contacted = contacted
  end))

  let equal a b = 
    (a # who = b # who) && (a # contact = b # contact)

end

module NetworkConnect = struct

  include Fmt.Make(struct
    type json t = <
      contact   : IRelatedInstance.t 
    >
  end)

  let connect contact = Some (`networkConnect (object
    method contact = contact
  end))

  let equal a b = (a # contact = b # contact)

end


module ChatRequest = struct

  include Fmt.Make(struct
    type json t = <
      who   : IAvatar.t ;
      topic : string ;
      where : [ `entity of IEntity.t | `instance of IInstance.t ]
    >
  end)

  let make who topic where = Some (`chatReq (object
    method who = who
    method topic = topic
    method where = where
  end))

  let equal a b = (a # who = b # who && a # topic = b # topic && a # where = b # where)

end


module Welcome = struct

  include Fmt.Make(struct
    type json t = <
      who     : IAvatar.t ;
      from    : IInstance.t ;
      context : [ `becomeMember "bm"
		| `inviteGroup  "ig" of IEntity.t
		| `inviteEvent  "ie" of IEntity.t ]
    >
  end)

  let who t = Some (t # who)

  let equal a b = 
    (a # who = b # who) && (a # from = b # from) && (a # context = b # context)

  let become_member who from = Some (`welcome (object
    method who     = who 
    method from    = from
    method context = `becomeMember
  end : t)) 

  let invite_to_group who from where = Some (`welcome (object
    method who     = who
    method from    = from
    method context = `inviteGroup (IEntity.decay where)
  end : t)) 

  let invite_to_event who from where = Some (`welcome (object
    method who     = who
    method from    = from
    method context = `inviteEvent (IEntity.decay where) 
  end : t))

end 

module Payload = struct

  include Fmt.Make(struct
    type json t = [ `myMembership      "mm" of MyMembership.t 
		  | `publishItem       "i"  of PublishItem.t
		  | `likeItem          "li" of LikeItem.t
		  | `commentItem       "ci" of CommentItem.t
		  | `welcome           "w"  of Welcome.t
		  | `joinEntity        "j"  of JoinEntity.t
		  | `joinPending       "jp" of JoinPending.t
		  | `networkInvite     "a"  of NetworkInvite.t
		  | `networkConnect    "c"  of NetworkConnect.t
		  | `chatReq           "cr" of ChatRequest.t
		  ]
  end)

  let to_channel = function
    | `myMembership   _ -> `myMembership
    | `likeItem       t -> `likeItem (t # on)
    | `commentItem    t -> `commentItem (t # on)
    | `publishItem    t -> `publishItem (t # what)
    | `welcome        _ -> `welcome
    | `joinEntity     t -> `joinEntity (t # what, t # kind)
    | `joinPending    t -> `joinPending (t # what)
    | `networkInvite  t -> `networkInvite (t # contact)
    | `networkConnect t -> `networkConnect (t # contact) 
    | `chatReq        r -> `chatReq (r # where) 

  let equal = function
    | `myMembership   x -> (function `myMembership   y -> MyMembership.equal   x y | _ -> false)
    | `likeItem       x -> (function `likeItem       y -> LikeItem.equal       x y | _ -> false)
    | `commentItem    x -> (function `commentItem    y -> CommentItem.equal    x y | _ -> false)
    | `welcome        x -> (function `welcome        y -> Welcome.equal        x y | _ -> false)
    | `joinEntity     x -> (function `joinEntity     y -> JoinEntity.equal     x y | _ -> false)
    | `joinPending    x -> (function `joinPending    y -> JoinPending.equal    x y | _ -> false)
    | `publishItem    x -> (function `publishItem    y -> PublishItem.equal    x y | _ -> false)
    | `networkInvite  x -> (function `networkInvite  y -> NetworkInvite.equal  x y | _ -> false)
    | `networkConnect x -> (function `networkConnect y -> NetworkConnect.equal x y | _ -> false)
    | `chatReq        x -> (function `chatReq        y -> ChatRequest.equal    x y | _ -> false)

end

module Data = Fmt.Make(struct
  let name = "Notification.t"
  type json t = <
    t    : MType.t ;
    who  : IUser.t ;
   ?chan : Channel.t = `welcome ;
    inst : IInstance.t option ;
    what : Payload.t list ;
    time : Float.t ;
    read : bool ;
   ?sent : bool = true
  >
end)

module MyTable = CouchDB.Table(MyDB)(INotification)(Data)

include Data

(* Signals -------------------------------------------------------------------------------- *)

module Signals = struct

  let on_send_call, on_send = Sig.make (Run.list_iter identity)

end

(* Counting unread items ------------------------------------------------------------------ *)

module Count = Fmt.Make(struct
  type json t = < 
    unread  "u" : int ; 
    pending "p" : int ; 
    total   "t" : int 
  > ;;
end) 

module CountView = CouchDB.ReduceView(struct
  module Key = Id
  module Value = Count
  module Reduced = Count
  module Design = Design
  let name   = "count"
  let map    = "if (doc.t == 'ntfy' && doc.read === false) { 
                  emit(doc.who,{t:doc.what.length,u:doc.what.length,p:0});
                }" 
  let reduce = "var r = { t:0, u:0, p:0 };
                for (var k in values) { 
                  r.t += values[k].t;
                  r.u += values[k].u;
                  r.p += values[k].p;
                }
                return r;" 
  let group  = true
  let level  = None
end) 

let count user = 
  let id = ICurrentUser.to_id user in 
  CountView.reduce id |> Run.map begin function
    | Some count -> count
    | None -> ( object method unread = 0 method pending = 0 method total = 0 end )
  end

(* Actually sending the notifications ------------------------------------------------------ *)

module Sending = Fmt.Make(struct
  module INotification = INotification
  type json t = < id : INotification.t ; nth : int >
end)

let mark_for_sending = 
  let task = Task.register "notify-send" Sending.fmt begin fun send _ ->
    let! data = ohm_req_or (return (Task.Finished send)) $ MyTable.get (send # id) in
    
    let! () = ohm begin 
    if not (data # sent) then 
      try 
	let what = BatList.nth (data # what) (send # nth) in (* May throw *)
	Signals.on_send_call (object
	  method id   = INotification.Assert.can_send (send # id)
	  method who  = data # who
	  method inst = data # inst
	  method what = what
	end) |> Run.map ignore
      with _ -> return ()
    else
      return () 
    end in 

    return (Task.Finished send)

  end in
  fun id nth -> 
    MModel.Task.delay 120.0 task (object 
      method id  = id
      method nth = nth
    end) |> Run.map ignore

(* Insert a new item (assuming that it's allowed) ------------------------------------------- *)

let _create ?instance ~what ~who () =  

  let channel = Payload.to_channel what in
  let unique  = Channel.unique instance channel who in
  let read    = channel = `welcome (* Welcome messages never count as unread... *) in

  let update retry id = function 
    | None -> return (Some 0, `put (object
      method t    = `Notification
      method chan = channel
      method what = [ what ]
      method inst = instance
      method who  = who
      method read = read
      method sent = false
      method time = Unix.gettimeofday ()
    end)) 
    | Some old -> 
      if old # read = true then 
	( let! _  = ohm $ MyUnique.remove_atomic unique (INotification.to_id id) in
	  let! () = ohm $ retry () in
          return (None, `keep) )
      else if List.exists (Payload.equal what) (old # what) then 
	return (None, `keep)
      else 
	return (Some (List.length (old # what)), `put (object
	  method t    = `Notification 
	  method chan = old # chan
	  method what = old # what @ [ what ]
	  method inst = old # inst
	  method who  = old # who
	  method read = old # read
	  method sent = old # sent
	  method time = Unix.gettimeofday ()
	end)) 
  in

  let rec insert n = 
    if n > 3 then 
      return (log "Notification._create : too many retries")
    else 
      let! id = ohm $ MyUnique.get unique in
      let id = INotification.of_id id in 
      let retry () = insert (n+1) in
      let! nth = ohm_req_or (return ()) $ MyTable.transaction id 
	(fun i -> MyTable.get i |> Run.bind (update retry i)) in
      mark_for_sending id nth 
  in
  insert 0
    
module Create = Fmt.Make(struct
  type json t = <
    make : IUser.t list ;     
    inst : IInstance.t option;
    what : Payload.t 
  > 
end)

let create = 
  let task = Task.register "notify-create" Create.fmt begin fun make _ ->
 
    let! _ = ohm $ Run.list_map begin fun who -> 
      _create ?instance:(make # inst) ~who ~what:(make # what) ()
    end (make # make)in

    return (Task.Finished (object 
      method make = [] 
      method inst = make # inst
      method what = make # what
    end))

  end in
  fun ?instance ~who ~what () ->
    match who with 
      | []    -> return ()
      | [who] -> _create ?instance ~who ~what ()
      |  _    -> let create = 
		   (object 
		     method make = who 
		     method inst = instance
		     method what = what
		    end)
		 in
		 MModel.Task.call task create |> Run.map ignore

(* Marking notifications as read. ---------------------------------------------------------- *)

let _read list = 
  list |> Run.list_map begin fun id ->

    let read old = 
      if old # read then (), `keep 
      else (), `put (object
	method t    = `Notification 
	method chan = old # chan
	method what = old # what 
	method inst = old # inst
	method who  = old # who
	method read = true
	method sent = true
  	method time = old # time 
      end) 
    in

    MyTable.transaction id (MyTable.if_exists read)
    |> Run.map ignore
  end 
  |> Run.map ignore

module IdList = Fmt.Make(struct
  module INotification = INotification
  type json t = INotification.t list 
end)

let _read_task = Task.register "notify-read" IdList.fmt begin fun list _ ->
  let! () = ohm $ _read list in return (Task.Finished [])
end

let read list =
  let list = List.map INotification.decay list in
  if List.length list < 2 then 
    _read list 
  else 
    MModel.Task.call _read_task list |> Run.map ignore

(* Reading notification details ------------------------------------------------------------- *)

module Fetch = Fmt.Make(struct
  type json t = IUser.t * bool * Float.t
end)

module FetchView = CouchDB.DocView(struct
  module Key = Fetch
  module Value = Fmt.Unit
  module Doc = Data
  module Design = Design
  let name = "fetch"
  let map  = "if (doc.t == 'ntfy') { 
                emit([doc.who,!doc.read,doc.time],null); 
              }"
end)

let _fetch ?limit user forced = 
  let startkey   = user, forced, max_float in
  let endkey     = user, forced, 0.0 in
  let descending = true in
  FetchView.doc_query
    ~startkey ~endkey ~descending ?limit () 
  |> Run.map (List.map begin fun item ->     
    forced, 
    (* Fetched items can be marked as read *)
    INotification.Assert.can_read (INotification.of_id item # id), 
    item # doc
  end) 

let fetch user count = 
  let user   = IUser.decay user in
    
  let! unread = ohm $ _fetch user true in
  let  found  = List.length unread in
  
  let! all = ohm (if found < count then 
      _fetch ~limit:(count-found) user false |> Run.map (fun more -> unread @ more)
    else
      return unread
  ) in
  
  let! _ = ohm $ read (List.map (fun (_,id,_) -> id) unread) in
  
  return all 

let bot_get nid = 
  let id = INotification.decay nid in
  MyTable.get id

let instance nid = 
  let! notif = ohm_req_or (return None) $ MyTable.get (INotification.decay nid) in
  return $ (notif # inst)
    
let from_link token cuid nid = 

  let id = INotification.decay nid in 

  let! notify = ohm_req_or (return `missing) $ MyTable.get id in

  let! user   = ohm_req_or (return (`not_connected notify)) begin 
  
    let user =  (* Are we already logged in? *)
      match cuid with 
	| Some cuid -> 
	  if IUser.Deduce.unsafe_is_anyone cuid = IUser.decay (notify # who) 
	  then Some cuid
	  else None
	| None -> None 
    in
    
    match user with 
      | Some user -> return (Some user)
      | None      -> 
	(* Can the token log us in ? *)
	match IUser.Deduce.from_login_token token (notify # who) with 
	  | None      -> return None
	  | Some user -> 
	    (* It can, but is auto-login enabled? *)
	    let! user_data = ohm_req_or (return None)
	      (MUser.get (IUser.Deduce.unsafe_can_view user)) 
	    in
	    if user_data # autologin then return (Some user) else return None
  end in
    
  let! () = ohm ( if not (notify # read) then read [id] else return () ) in
  return (`connected (user, notify))

(* Obliterating notifications -------------------------------------------------------------- *)

module ByUserView = CouchDB.DocView(struct
  module Key    = IUser
  module Value  = Fmt.Unit
  module Doc    = Data
  module Design = Design
  let name = "by_user"
  let map  = "if (doc.t == 'ntfy') emit(doc.who,null);"
end)

let _ = 
  let obliterate nid = MyTable.transaction nid MyTable.remove in 
  let on_obliterate_user uid =
    let! list = ohm $ ByUserView.doc uid in 
    let! _ = ohm $ Run.list_map (#id |- INotification.of_id |- obliterate) list in 
    return ()
  in
  Sig.listen MUser.Signals.on_obliterate on_obliterate_user
		
(* Actually generating the notifications. -------------------------------------------------- *)

module Generate = struct

  (* Became admin/member ------------------------------------------------------------------- *)

  let _ = 
    let upgrade status (from, avatar, instance) =      
      let! from = req_or (return ()) from in
      if IAvatar.decay from = avatar then return () else
	let! details = ohm $ MAvatar.details avatar in
	let! user = req_or (return ()) (details # who) in
	let! what = req_or (return ()) $
	  MyMembership.make (IAvatar.decay from) status 
	in
	create ~who:[user] ~instance ~what ()
    in

    Sig.listen MAvatar.Signals.on_upgrade_to_admin  (upgrade `toAdmin) ;
    Sig.listen MAvatar.Signals.on_upgrade_to_member (upgrade `toMember) 

  (* Liked item --------------------------------------------------------------------------- *)

  module ItemLike = Fmt.Make(struct
    type json t = IAvatar.t * IItem.t * (IAvatar.t list)
  end)

  let _ = 
    let _item_notify =
 
      let task = Task.register "like-item-notify" ItemLike.fmt begin
	fun (sender,item,avatars) _ ->
	  let notify_avatar avatar =  
	    if avatar = sender then return () else
	      let! details  = ohm $ MAvatar.details avatar in
	      let! instance = req_or (return ()) (details # ins) in
	      let! user     = req_or (return ()) (details # who) in
	      let! what     = req_or (return ()) $
		LikeItem.make sender item
	      in
	      create ~who:[user] ~instance ~what ()
	  in
	  let! _ = ohm $ Run.list_map notify_avatar avatars in
	  return $ Task.Finished (sender,item,avatars)
      end in

      fun sender item list ->
	let sender = IAvatar.decay sender in
	let item   = IItem.decay item in
	let list   = BatList.remove_all list sender in
	let list   = BatList.sort_unique compare list in 
	if list <> [] then 
	  MModel.Task.call task (sender,item,list) |> Run.map ignore
	else
	  return ()

    in
    Sig.listen MLike.Signals.on_like begin fun (who,what) ->
      match what with 
	| `item item -> let itid = IItem.Assert.bot item in (* Acting as bot to send notifs *)
			let! interested = ohm $ MItem.interested itid in
			_item_notify who item interested
	| _          -> return ()
    end

  (* Replied to item ----------------------------------------------------------------------- *)

  module ItemReply = Fmt.Make(struct
    type json t = IComment.t * IAvatar.t * IItem.t * (IAvatar.t list)
  end)

  let _ = 
    let _item_notify = 
      
      let task = Task.register "comment-item-notify" ItemReply.fmt begin
	fun (comment,sender,item,avatars) _ ->
	  let notify_avatar avatar = 
	    if sender = avatar then return () else 
	      let! details  = ohm $ MAvatar.details avatar in
	      let! instance = req_or (return ()) (details # ins) in
	      let! user     = req_or (return ()) (details # who) in
	      let! what     = req_or (return ()) $
		CommentItem.make sender item comment
	      in
	      create ~who:[user] ~instance ~what ()
	  in
	  let! _ = ohm $ Run.list_map notify_avatar avatars in
	  return $ Task.Finished (comment,sender,item,avatars)
      end in
      
      fun comment sender item list ->
	let comm   = IComment.decay comment in
	let sender = IAvatar.decay sender in
	let item   = IItem.decay item in
	let list   = BatList.remove_all list sender in
	let list   = BatList.sort_unique compare list in 
	if list <> [] then 
	  MModel.Task.call task (comm,sender,item,list) |> Run.map ignore
	else
	  return ()
    in
    Sig.listen MComment.Signals.on_create begin fun (id,comment) ->
      let  avatar     = comment # who in
      let  itid       = IItem.Assert.bot (comment # on) in (* Acting as bot to send notifs *)
      let! interested = ohm $ MItem.interested itid in 
      _item_notify id avatar itid interested
    end


  (* Sending an item ----------------------------------------------------------------------- *)

  module PublishItemArgs = Fmt.Make(struct
    type json t = IAvatar.t * IItem.t * IFeed.t
  end)

  let send_published_task = Task.register "published-notify" PublishItemArgs.fmt
    begin fun (from,item,fid) _ ->

      let finish = return (Task.Finished (from,item,fid)) in
      
      (* Acting as bot to propagate messages *)
      let! feed  = ohm_req_or finish $ MFeed.bot_get (IFeed.Assert.bot fid) in
      
      let! iid,eid = ohm_req_or finish begin
	match MFeed.Get.owner feed with 
	  (* Don't notify for new private messages, it's done by module MMessage *)
	  | `of_message  _ -> return None
	  | `of_instance i -> return (Some (i,None))
	  | `of_entity   e -> let! entity = ohm_req_or (return None) $ MEntity.naked_get e in
			      return $ Some (MEntity.Get.instance entity,Some e)
      end in 

      let riid = IInstance.Assert.rights iid in
            
      let! notified    = ohm $ MFeed.Get.notified feed in
      let! readers     = ohm $ MReverseAccess.reverse riid notified in

      let! blockers    = ohm $ MBlock.all_blockers (`Feed fid) in

      let unblocked_readers =
	readers
        |> List.filter (fun avatar -> not (BatPSet.mem avatar blockers) && from <> avatar) 
        |> BatList.sort_unique compare 
      in

      let! details = ohm $ Run.list_map MAvatar.details unblocked_readers in      
      let who = BatList.sort_unique compare (BatList.filter_map (fun d -> d # who) details) in

      let! what = req_or finish $ PublishItem.make from item in
      
      let! _    = ohm (create ~instance:iid ~who ~what ()) in

      finish
      
    end

  module ChatReqArgs = Fmt.Make(struct
    type json t = IAvatar.t * IItem.t * IFeed.t * string
  end)

  let send_chatreq_task = Task.register "chatreq-notify" ChatReqArgs.fmt
    begin fun (from,item,fid,topic) _ ->

      let finish = return (Task.Finished (from,item,fid,topic)) in
      
      (* Acting as bot to propagate messages *)
      let! feed  = ohm_req_or finish $ MFeed.bot_get (IFeed.Assert.bot fid) in
      
      let! iid,eid = ohm_req_or finish begin
	match MFeed.Get.owner feed with 
	  (* Private chat rooms do not exist *)
	  | `of_message  _ -> return None
	  | `of_instance i -> return (Some (i,None))
	  | `of_entity   e -> let! entity = ohm_req_or (return None) $ MEntity.naked_get e in
			      return $ Some (MEntity.Get.instance entity,Some e)
      end in 

      let riid = IInstance.Assert.rights iid in
            
      let! notified    = ohm $ MFeed.Get.notified feed in
      let! readers     = ohm $ MReverseAccess.reverse riid notified in

      let! blockers    = ohm $ MBlock.all_blockers (`Feed fid) in

      let unblocked_readers =
	readers
        |> List.filter (fun avatar -> not (BatPSet.mem avatar blockers) && from <> avatar) 
        |> BatList.sort_unique compare 
      in

      let! details = ohm $ Run.list_map MAvatar.details unblocked_readers in      
      let who = BatList.sort_unique compare (BatList.filter_map (fun d -> d # who) details) in

      let! what = req_or finish $ ChatRequest.make from topic 
	(match eid with None -> `instance iid | Some eid -> `entity eid) in
      
      let! _    = ohm (create ~instance:iid ~who ~what ()) in

      finish
      
    end

  let send_published item =

    match item # payload with 
      | `Message _ | `MiniPoll _ -> begin
 
	let! author = req_or (return ()) $ MItem.author (item # payload) in  
	let! feed   = req_or (return ()) begin match item # where with 
	  | `feed fid -> Some fid
	  | `album  _ 
	  | `folder _ -> None 
	end in 
	let itid = IItem.decay (item # id) in 

	let! _ = ohm $ MModel.Task.call send_published_task (author,itid,feed) in
	return ()

      end

      | `ChatReq r -> begin

	let  author = r # author in
	let! feed =  req_or (return ()) begin match item # where with 
	  | `feed fid -> Some fid
	  | `album  _ 
	  | `folder _ -> None 
	end in 
	let itid = IItem.decay (item # id) in 

	let! _ = ohm $ MModel.Task.call send_chatreq_task (author,itid,feed,r#topic) in
	return ()

      end

      | `Image _ | `Doc _ | `Chat _ -> return () 

  let () = Sig.listen MItem.Signals.on_post send_published
      
  (* To be validated  ---------------------------------------------------------------------- *)

  module SendToValidateArgs = Fmt.Make(struct
    type json t = IAvatar.t option * IGroup.t * IAvatar.t
  end)

  let send_to_validate_task = Task.register "to_validate-notify" SendToValidateArgs.fmt
    begin fun (from_opt,gid,avatar) _ ->

      let finish = return $ Task.Finished (from_opt,gid,avatar) in

      let! group = ohm_req_or finish $ MGroup.naked_get gid in 
      let! eid   = req_or finish     $ MGroup.Get.entity group in 

      let! access  = ohm $ MGroup.Get.write_access group in
      let instance = MGroup.Get.instance group in 

      (* We need to propagate to all administrators *)
      let iid = IInstance.Assert.rights instance in 

      let! list = ohm $ MReverseAccess.reverse iid [access] in

      let not_to_self manager = not (manager = avatar || Some manager = from_opt) in

      let avatars = List.filter not_to_self list in 

      let! details = ohm $ Run.list_map MAvatar.details avatars in
      
      let who = BatList.sort_unique compare (BatList.filter_map (fun d -> d # who) details) in

      let! what = req_or finish $ JoinPending.make eid avatar in

      let! _ = ohm $ create ~instance ~who ~what () in
      
      finish

  end 

  let to_validate from_opt join = 
    let gid    = join.MMembership.where in
    let avatar = join.MMembership.who   in
    MModel.Task.call send_to_validate_task (from_opt,gid,avatar) |> Run.map ignore

  (* Invited to a group ------------------------------------------------------------------- *) 

  module SendInvitedArgs = Fmt.Make(struct
    type json t = IAvatar.t * IGroup.t * IAvatar.t
  end) 

  let send_invited_task = Task.register "invited-notify" SendInvitedArgs.fmt
    begin fun (from,gid,avatar) _ -> 

      let finish = return (Task.Finished (from,gid,avatar)) in

      if from = avatar then finish else begin 
	
	let! details    = ohm $ MAvatar.details avatar in
	let! who        = req_or finish  details # who in
	let! group      = ohm_req_or finish $ MGroup.naked_get gid in
	let! eid        = req_or finish $ MGroup.Get.entity group in
	let! entity     = ohm_req_or finish $ MEntity.naked_get eid in
	
	let kind     = MEntity.Get.kind entity in	
	let instance = MEntity.Get.instance entity in 
	
	let! what = req_or finish $ JoinEntity.invite from eid kind in
	
	let! _ = ohm $ create ~instance ~who:[who] ~what () in

	finish
	  
      end
    end

  let invited from join =
    let gid    = join.MMembership.where in
    let avatar = join.MMembership.who   in
    MModel.Task.call send_invited_task (from,gid,avatar) |> Run.map ignore

  (* Handling all join updates at once ---------------------------------------------------- *)

  let _ = 
    let update (_,join) = 

      let! () = ohm begin 
	if not join.MMembership.admin_act then return () else to_validate None join
      end in

      let! () = ohm begin 
	if not join.MMembership.user_act then return () else
	  let! _, _, from = req_or (return ()) join.MMembership.invited in
	  invited from join 
      end in 

      return ()
    in

    Sig.listen MMembership.Signals.after_update update

  (* Related instance connection -------------------------------------------------------- *)

  let _  = 

    let connect connection = 

      let instance = connection # followed in 

      (* We need to propagate to all administrators *)
      let  iid    = IInstance.Assert.rights instance in 
      let! admins = ohm $ MReverseAccess.reverse iid [`Admin] in

      let! users  = ohm $ Run.list_map begin fun aid -> 
	MAvatar.details aid |> Run.map (#who)
      end admins in 

      let  who = BatList.filter_map identity users in 

      let! what = req_or (return ()) $ NetworkConnect.connect (connection # relation) in	
      let! _ = ohm $ create ~instance ~who ~what () in
      
      return () 
      
    in

    Sig.listen MRelatedInstance.Signals.after_connect connect

  (* Follow related instance invites ---------------------------------------------------- *)

  let _ = 
    let update (from,rid,text,uid) = 

      let! data      = ohm_req_or (return ()) $ MRelatedInstance.get_data rid in 
      let  instance  = data.MRelatedInstance.Data.related_to in
      let! contacted = req_or (return ()) $ begin 
	match data.MRelatedInstance.Data.bind with 
	  | `Bound   _ -> None 
	  | `Unbound u -> Some u.MRelatedInstance.Unbound.name
      end in

      let! what     = req_or (return ()) $
	NetworkInvite.invite (IAvatar.decay from) text (IRelatedInstance.decay rid) contacted
      in

      create ~who:[uid] ~instance ~what ()
    in
    
    Sig.listen MRelatedInstance.Signals.add_owner update

end
