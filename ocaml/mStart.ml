(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module MyDB = CouchDB.Convenience.Database(struct let db = O.db "instance-start" end)

module Data = struct
  module T = struct
    type json t = {
      invite_members "i" : bool ;
      write_post     "w" : bool ;
      broadcast      "c" : bool ;
      add_picture    "p" : bool ;
      create_event   "e" : bool ;
      another_event  "a" : bool ;
     ?invite_network "n" : bool = false 
    }
  end
  include T
  include Fmt.Extend(T)
end

module Step = Fmt.Make(struct
  type json t = 
    [ `InviteMembers 
    | `AGInvite
    | `WritePost
    | `Broadcast
    | `AddPicture
    | `CreateEvent
    | `CreateAG
    | `AnotherEvent 
    | `InviteNetwork ]
end)

module MyTable = CouchDB.Table(MyDB)(IInstance)(Data)

let compute iid = 

  let! members  = ohm $ MAvatar.usage (IInstance.Deduce.see_contacts iid) in

  let! instance = ohm $ MInstance.get iid in
  let  picture  = BatOption.bind (#pic) instance in 

  let! event    = ohm $ MEntity.get_last_real_event_date iid in 
  let  date     = BatOption.default "99991231" $ BatOption.bind identity event in
  
  let! fid  = ohm $ MFeed.bot_find (IInstance.decay iid) None in 
  let! post = ohm begin 
    (* We're administrators of the instance! *)
    let fid = IFeed.Assert.read fid in
    MItem.exists (`feed fid)
  end in 

  let! network  = ohm $ MRelatedInstance.count iid in 

  let recent_time = Unix.gettimeofday () -. 7. *. 24. *. 3600. in
  let recent_date = MFmt.date_of_float recent_time in 

  let! broadcast = ohm $ MBroadcast.current (IInstance.decay iid) ~count:1 in

  return Data.({
    invite_members = (members > 1) ;
    add_picture    = (picture <> None) ;
    create_event   = (event   <> None) ;
    another_event  = (date    >  recent_date) ;
    write_post     =  post ;
    invite_network = (network # following > 0) ; 
    broadcast      = (broadcast <> [])
  })

let merge old t = 
  Data.({ t with 
    invite_members = old.invite_members || t.invite_members ;
    write_post     = old.write_post     || t.write_post ;
    create_event   = old.create_event   || t.create_event ;
    broadcast      = old.broadcast      || t.broadcast
  })

let get ?(force=false) iid = 

  let! old_opt = ohm $ MyTable.get (IInstance.decay iid) in
  
  let! fresh = ohm begin 
    match old_opt with 
      | Some old when force = false -> return old
      | Some old                    -> let! fresh = ohm $ compute iid in 
				       return $ merge old fresh 
      | None                        -> compute iid 
  end in 

  let! () = ohm begin 
    if Some fresh <> old_opt then 
      let! _ = ohm $ MyTable.transaction (IInstance.decay iid) (MyTable.insert fresh) in
      return () 
    else
      return ()
  end in
  
  return fresh 

let step_allowed data = function
  | `InviteMembers 
  | `AGInvite      -> not data.Data.invite_members
  | `WritePost     -> not data.Data.write_post
  | `AddPicture    -> not data.Data.add_picture 
  | `InviteNetwork -> not data.Data.invite_network 
  | `CreateAG
  | `CreateEvent   -> not data.Data.create_event 
  | `AnotherEvent  -> not data.Data.another_event
  | `Broadcast     -> not data.Data.broadcast

let next_step data steps = 
  try Some (List.find (step_allowed data) steps) 
  with _ -> None

let numbered_step = function 
  | `InviteMembers 
  | `WritePost     
  | `AddPicture    
  | `InviteNetwork 
  | `CreateEvent   
  | `Broadcast
  | `CreateAG
  | `AGInvite      -> true
  | `AnotherEvent  -> false

let step_number step steps = 
  if numbered_step step then
    match BatList.index_of step steps with 
      | Some i -> string_of_int (i+1) 
      | None   -> "!"
  else "!"
