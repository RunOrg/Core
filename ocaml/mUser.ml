(* © 2012 RunOrg *)

open Ohm
open Ohm.Util 
open BatPervasives
open Ohm.Universal

module Registry = OhmCouchRegistry.Make(struct
  module Id = IUser
  module Store = struct
    let host = "localhost"
    let port = 5984
    let database = O.db "user-r"
  end
end)

module MyDB = CouchDB.Convenience.Database(struct let db = O.db "user" end)

module Design = struct
  module Database = MyDB
  let name = "user" 
end

module Notification = Fmt.Make(struct
  type json t = [ `message       "ms"
		| `myMembership  "mm"
		| `likeItem      "li"
		| `commentItem   "ci"
		| `welcome       "w"
		| `subscription  "js"
		| `event         "je" 
		| `forum         "jf"
		| `album         "ja"
		| `group         "jg"
		| `poll          "jp"
		| `course        "jc"
		| `item          "i"
		| `pending       "p"
		| `digest        "d"
		| `networkInvite "n"
		| `chatReq       "cr" ]
end)

module Data = struct
  module Float = Fmt.Float
  module T = struct
    type json t = {
      t          : MType.t ;
      firstname  : string ;
      lastname   : string ;
      passhash   : string option ;
      email      : string ;
     ?emails     : (!string, bool) Ohm.ListAssoc.t = [] ;
      confirmed  : bool   ;
     ?destroyed  : Float.t option ;
     ?autologin  : bool = true ; 
     ?facebook   : OhmFacebook.t option ; 
     ?picture    : IFile.t option ;
     ?birthdate  : Date.t option ;
     ?phone      : string option ;
     ?cellphone  : string option ;
     ?address    : string option ;
     ?zipcode    : string option ;
     ?city       : string option ;
     ?country    : string option ;
     ?gender     : [`m|`f] option ;
     ?share      : MFieldShare.t list = [`basic ; `email] ;
     ?blocktype  : Notification.t list = [] ;
     ?joindate   : Float.t = 0.0 ;
     ?white      : IWhite.t option
    }

    (* Fix the current object state *)
    let fix t = 
      let emails =
	(t.email, t.confirmed) :: BatList.remove_if (fun (e,_) -> e = t.email) t.emails in
      let email, confirmed = 
	if t.confirmed then t.email, true else 
	  try List.find snd emails with _ -> t.email, false 
      in
      let joindate = 
	if confirmed && t.joindate < 1.0 && t.destroyed = None 
	then Unix.gettimeofday () else t.joindate
      in 
      { t with emails ; email ; confirmed ; joindate }
      
    let t_of_json json = 
      fix (t_of_json json)

    let json_of_t t = 
      json_of_t (fix t)

  end
  include T
  include Fmt.Extend(T)

end

module Tbl = CouchDB.Table(MyDB)(IUser)(Data)

type t = <
  firstname : string option ;
  lastname  : string option ;
  fullname  : string ;
  passhash  : string option ;
  email     : string ;
  emails    : (string * bool) list ;
  autologin : bool ; 
  confirmed : bool ;
  destroyed : float option ;
  facebook  : OhmFacebook.t option ;
  picture   : [`GetPic] IFile.id option ;
  birthdate : Date.t option ;
  phone     : string option ;
  cellphone : string option ;
  address   : string option ;
  zipcode   : string option ;
  city      : string option ;
  country   : string option ;
  gender    : [`m|`f] option ;
  share     : MFieldShare.t list ;
  blocktype : Notification.t list ;
  joindate  : float ;
  white     : IWhite.t option
> ;;

let extract t = Data.(object
  method firstname  = if t.firstname <> "" then Some t.firstname else None
  method lastname   = if t.lastname <> "" then Some t.lastname else None
  method fullname   = 
    if t.firstname = "" then t.email
    else t.firstname ^ (if t.lastname <> "" then " " ^ t.lastname else "")
  method passhash   = t.passhash
  method email      = EmailUtil.canonical t.email
  method emails     = List.map (fun (email,confirmed) -> EmailUtil.canonical email, confirmed) t.emails
  method autologin  = t.autologin
  method confirmed  = t.confirmed
  method destroyed  = t.destroyed 
  method facebook   = t.facebook
  method picture    = BatOption.map IFile.Assert.get_pic t.picture (* Can view user *)
  method birthdate  = t.birthdate
  method phone      = t.phone
  method cellphone  = t.cellphone
  method address    = t.address
  method zipcode    = t.zipcode
  method city       = t.city
  method country    = t.country
  method gender     = t.gender
  method share      = t.share
  method blocktype  = t.blocktype
  method joindate   = t.joindate
  method white      = t.white
end)

let default = Data.({
  t         = `User ;
  firstname = "" ;
  lastname  = "" ; 
  passhash  = None ; 
  email     = "" ; 
  emails    = [] ;
  facebook  = None ;
  destroyed = None ;
  autologin = true ;
  confirmed = false ;
  birthdate = None ;
  picture   = None ;
  phone     = None ;
  cellphone = None ;
  address   = None ;
  zipcode   = None ;
  city      = None ;
  country   = None ;
  gender    = None ;
  share     = [`basic ; `email] ;
  blocktype = [] ; 
  joindate  = 0.0 ;
  white     = None 
})

module Signals = struct

  let on_create_call,     on_create     = Sig.make (Run.list_iter identity)
  let on_update_call,     on_update     = Sig.make (Run.list_iter identity)
  let on_confirm_call,    on_confirm    = Sig.make (Run.list_iter identity)
  let on_obliterate_call, on_obliterate = Sig.make (Run.list_iter identity)
  let on_merge_call,      on_merge      = Sig.make (Run.list_iter identity)

end

let () = 
  let! uid, _ = Sig.listen Signals.on_confirm in
  MAdminLog.log ~uid MAdminLog.Payload.UserConfirm

(*
  Confirmed users : all confirmed e-mails.
  Non-confirmed users : primary e-mail only. 
*)

module ByEmailView = CouchDB.DocView(struct
  module Key    = Fmt.String
  module Value  = Fmt.Bool
  module Doc    = Data
  module Design = Design
  let name = "by_email"
  let map  = "if (doc.t == 'user') {
    emit(doc.email.toLowerCase(),doc.confirmed);
    if (doc.confirmed && doc.emails) {
      for (var email in doc.emails) 
        if (email != doc.email && doc.emails[email])      
          emit(email.toLowerCase(),true);
    } 
  }" 
end)

let by_email email = 
  ByEmailView.doc (EmailUtil.canonical email)
  |> Run.map (Util.first 
		 |- BatOption.map (#id |- IUser.of_id))

module ByFacebookView = CouchDB.DocView(struct
  module Key = OhmFacebook
  module Value = Fmt.Bool
  module Doc = Data
  module Design = Design
  let name = "by_facebook"
  let map    = "if (doc.t == 'user' && doc.facebook) emit(doc.facebook,doc.confirmed)" 
end)

let by_facebook uid = 
  ByFacebookView.doc uid
  |> Run.map (Util.first |- BatOption.map (#id |- IUser.of_id))

class type user_short = object
  method firstname : string
  method lastname  : string
  method password  : string option 
  method email     : string
  method white     : IWhite.t option
end 

let confirm uid = 
 
  let uid = IUser.decay uid in 
  let update user = 
    if user.Data.confirmed then None, `keep else 	      
      let o = Data.({ user with confirmed = true }) in
      (Some o), `put o
  in
  
  let! result = ohm $ Tbl.transact uid 
    (function
      | None      -> return (None,`keep)
      | Some data -> let result, act = update data in
		     return (Some result, act))
  in

  match result with 
    | Some (Some o) -> let! () = ohm $ Signals.on_confirm_call (uid, extract o) in
		       return true
    | Some None -> return true
    | None   -> return false
        
let confirmed uid = 
  let! user = ohm_req_or (return false) $ Tbl.get (IUser.decay uid) in
  return user.Data.confirmed

let blocks uid = 
  let! user = ohm_req_or (return []) $ Tbl.get (IUser.decay uid) in
  return user.Data.blocktype

let confirmed_time uid = 
  let! user = ohm_req_or (return None) $ Tbl.get (IUser.decay uid) in 
  return (if user.Data.confirmed then Some user.Data.joindate else None) 

let quick_create (user : user_short) = 
  let! found = ohm $ by_email (user # email) in

  let id, exists = match found with 
    | Some id -> IUser.decay id, true
    | None    -> IUser.of_id (Id.gen ()) , false
  in
  
  let update exists = 
    
    let collision = match exists with
      | Some user -> user.Data.confirmed
      | None      -> false
    in
    
    if collision then `duplicate (IUser.decay id), `keep
    else 
      let clip s = if String.length s > 200 then String.sub s 0 200 else s in      
      let email  = clip (EmailUtil.canonical (user # email)) in 
      let obj = Data.({
	default with
	  firstname = clip (user # firstname) ;
	  lastname  = clip (user # lastname) ;
	  passhash  = BatOption.map ConfigKey.passhash (user # password) ;
	  email     ;
	  white     = user # white ; 
      }) in
      
      `created (IUser.decay id, obj), `put obj
  in
  
  let! result = ohm $ Tbl.transact id (update |- return) in
  match result with
    | `duplicate id      -> return $ `duplicate id
    | `created (id, obj) -> let! () = ohm $ (* Created above. *)
			      ( if exists then 
				  Signals.on_update_call
				    (IUser.Assert.updated id, extract obj) 
				else 
				  Signals.on_create_call
				    (IUser.Assert.created id, extract obj) )
			    in 
			    return $ `created (IUser.Assert.is_new id)

let listener_create email = 

  let! found = ohm $ by_email email in

  let id, exists = match found with 
    | Some id -> IUser.decay id, true
    | None    -> IUser.of_id (Id.gen ()) , false
  in
  
  let update exists = 

    let default = match exists with 
      | Some user -> user
      | None      -> default
    in 
    
    let collision = match exists with
      | Some user -> user.Data.confirmed
      | None      -> false
    in
    
    if collision then (id, true), `keep
    else 
      let clip s = if String.length s > 200 then String.sub s 0 200 else s in      
      let email  = clip (EmailUtil.canonical email) in 
      let obj = Data.({ default with email }) in
      
      (id, false), `put obj
  in
  
  let! id, exists = ohm $ Tbl.transact id (update |- return) in 
  
  if exists then return None else
    (* We have created or retrieved a new, unconfirmed listener *)
    return $ Some (IUser.Assert.is_new id)

let _facebook_update uid facebook details = 

  let self = 
    (* Acting as self for the picture *)
    IUser.Assert.is_self uid
  in

  let pic_id = 
    (* It's a facebook picture, so we can upload it. *)
    IFile.Assert.put_pic (IFile.gen ())
  in

  let the_pic = Some (IFile.decay pic_id) in

  let update exists = 
	  
    let clip s = if String.length s > 200 then String.sub s 0 200 else s in      

    let email = EmailUtil.canonical (details # email) in
    let email, emails = match exists with 
      | None      -> email, [email, true]
      | Some user -> user.Data.email, user.Data.emails 
    in

    let picture = match exists with 
      | None      -> the_pic
      | Some user -> if user.Data.picture = None then the_pic else user.Data.picture
    in

    let default = BatOption.default default exists in

    let obj = Data.({
      default with
	firstname = clip (details # firstname) ;
	lastname  = clip (details # lastname) ;
	email     ; 
	emails    ; 
	facebook  = Some facebook ;
	confirmed = true ;
	picture   ;
	gender    = details # gender ;
	joindate  = Unix.gettimeofday ()
    }) in

    let created, confirmed = match exists with 
      | None      -> true, true 
      | Some user -> false, not user.Data.confirmed
    in 
	  
    (created, confirmed, obj), `put obj
      
  in
	
  let! () = ohm $ MFile.set_facebook_pic pic_id self details in
	
  let! created, confirmed, obj = ohm $
    Tbl.transact uid (update |- return)
  in 
  
  let! () = ohm begin 
    if not created then 
      Signals.on_update_call (IUser.Assert.updated uid, extract obj) 
    else 
      Signals.on_create_call (IUser.Assert.created uid, extract obj) 
  end in
  
  let! () = ohm begin 
    if confirmed then 
      Signals.on_confirm_call (IUser.decay uid, extract obj) 
    else 
      return ()
  end in

  return ()

let facebook_bind user facebook details = 
  
  let uid = IUser.decay user in 

  (* Check that neither fbid nor email is already taken by someone _else_ *)
  
  let! bound = ohm $ by_facebook facebook in  
  let! () = true_or (return false) (bound = None || bound = Some uid) in
  
  let! email = ohm $ by_email (details # email) in  
  let! () = true_or (return false) (bound = None || bound = Some uid) in

  (* Confirm the user *)
  
  let! () = ohm $ _facebook_update uid facebook details in

  return true
	  
let facebook_create facebook details = 

  let! bound = ohm $ by_facebook facebook in
  match bound with 
    | Some _ -> return None (* Already exists : no creation. *)
    | None   -> let! found = ohm $ by_email (details # email) in
		let  id = BatOption.default (IUser.gen ()) found in
		let! () = ohm $ _facebook_update id facebook details in
		return $ Some id

let owns_email user email = 
  let email = EmailUtil.canonical email in 
  user.Data.confirmed && (
    EmailUtil.canonical user.Data.email = email 
    || List.exists (fun (email',confirmed) -> confirmed && EmailUtil.canonical email' = email) user.Data.emails
  )

let prove_email uid email = 
  ConfigKey.prove [ "confirm_email" ; IUser.to_string uid ; EmailUtil.canonical email ]

let is_email_proof uid email proof = 
  ConfigKey.is_proof proof [ "confirm_email" ; IUser.to_string uid ; EmailUtil.canonical email ]

let add_email ~uid ~email = 

  let uid   = IUser.decay uid in 
  let email = EmailUtil.canonical email in 

  let update uid = 
    let! user = ohm_req_or (return (`missing,`keep)) $ Tbl.get uid in    
    if owns_email user email then return (`ok,`keep) else
      let o = Data.({ 
	user with emails =
	  (email,false) :: (List.filter (fun (e,c) -> c || EmailUtil.canonical e <> email) user.emails)
      }) in
      let proof = prove_email uid email in 
      return (`prove proof, `put o)
  in

  Tbl.Raw.transaction uid update

let confirm_email ~uid ~proof = 

  let uid = IUser.decay uid in 

  let update uid = 

    let! user  = ohm_req_or (return (`missing,`keep)) $ Tbl.get uid in
    let! email = req_or (return (`missing,`keep)) begin
      try Some (BatList.find_map 
		  (fun (e,c) -> if not c && is_email_proof uid e proof then Some e else None)
		  user.Data.emails)
      with _ -> None
    end in
    
    let! uid' = ohm $ by_email email in 
    
    if uid' <> None && uid' <> Some uid then return (`taken, `keep) else
      let emails = List.map 
	(fun (e,c) -> if e = email then (e,true) else (e,c)) user.Data.emails 
      in
      
      return (`ok, `put Data.({ user with emails }))

  in

  Tbl.Raw.transaction uid update

class type user_full = object
  method firstname : string
  method lastname  : string
  method email     : string
  method birthdate : Date.t option
  method phone     : string option
  method cellphone : string option
  method address   : string option
  method zipcode   : string option
  method city      : string option
  method country   : string option
  method picture   : [`GetPic] IFile.id option 
  method gender    : [`m|`f] option
  method white     : IWhite.t option
end

let user_bind (user : user_full) = 

  let! id = ohm begin 
     if user # email = "" 
     then return None 
     else by_email (user # email)
  end in
    
  let id = match id with 
    | Some id -> id
    | None    -> IUser.gen ()
  in

  (* Returns "created?" and saved object *)
  let update exists =
    
    match exists with 
      | Some user when user.Data.confirmed -> (false, user), `keep 

      | _ -> let clip  s = if String.length s > 200 then String.sub s 0 200 else s in      
	     let oclip s = BatOption.map clip s in
	     let email   = clip (EmailUtil.canonical (user # email)) in 
	     let obj = Data.({
	       default with 
		 firstname = clip (user # firstname) ;
		 lastname  = clip (user # lastname) ;
		 email     ;
		 emails    = [ email, false ] ; 
		 birthdate = user # birthdate ;
		 phone     = oclip (user # phone) ;
		 cellphone = oclip (user # cellphone) ;
		 address   = oclip (user # address) ;
		 city      = oclip (user # city) ;
		 country   = oclip (user # country) ;
		 zipcode   = oclip (user # zipcode) ;
		 picture   = BatOption.map IFile.decay (user # picture) ;
		 gender    = user # gender ;
		 white     = user # white
	     }) in
	     
	     (true, obj), `put obj
  in
  
  let! (created,obj) = ohm $ Tbl.transact id (update |- return) in

  let! () = ohm begin 
    if created then 
      (* created above *) 
      let created = IUser.Assert.created id in
      Signals.on_create_call (created, extract obj)
    else
      return ()
  end in

  return id

module Share = struct

  let set uid share =

    let id = IUser.decay uid in
    let share = if List.mem `basic share then share else `basic :: share in

    let update e = 
      let o = Data.({ e with share }) in
      if share <> e.Data.share
      then Some o, `put o 
      else None, `keep 
    in

    let! result = ohm $ Tbl.transact id 
      (function
	| None -> return (None, `keep) 
	| Some user -> return (update user))
    in 
    match result with 
      | Some o ->  
	(* Updated above. *) 
	let updated = IUser.Assert.updated uid in
	Signals.on_update_call (updated , extract o) 
      | _             -> return ()
  
end

class type user_edit = object
  method firstname : string
  method lastname  : string
  method birthdate : Date.t option
  method phone     : string option
  method cellphone : string option
  method address   : string option
  method zipcode   : string option
  method city      : string option
  method country   : string option
  method gender    : [`m|`f] option
end


let update uid (t:user_edit) = 

  let id = IUser.decay uid in
  let clip  n s = if String.length s > n then String.sub s 0 n else s in
  let oclip n s = BatOption.map (clip n) s in
  let update e = 
    let o = Data.({
      e with 
	firstname =  clip 50  (t # firstname) ;
	lastname  =  clip 50  (t # lastname) ;
	birthdate = t # birthdate ;
	phone     = oclip 20  (t # phone) ;
	cellphone = oclip 20  (t # cellphone) ; 
	address   = oclip 100 (t # address) ;
	zipcode   = oclip 10  (t # zipcode) ;
	city      = oclip 80  (t # city) ;
	country   = oclip 80  (t # country) ;
	gender    = t # gender ;
    }) in
    if o <> e then Some o, `put o else None, `keep 
  in

  let! result = ohm $ Tbl.transact id 
    (function 
      | None      -> return (None,`keep)
      | Some data -> return (update data))
  in
  match result with 
    | Some o ->
      (* Updated above. *)
      let updated = IUser.Assert.updated uid in
      Signals.on_update_call (updated , extract o) 
    | _             -> return ()

let set_pic uid pic = 

  let id = IUser.decay uid in
  let fid = BatOption.map IFile.decay pic in 
  let update e = 
    let o = Data.({ e with picture = fid }) in     
    if o <> e then Some o, `put o else None, `keep 
  in

  let! result = ohm $ Tbl.transact id 
    (function 
      | None -> return (None, `keep) 
      | Some user -> return (update user))
  in
  match result with 
    | Some o ->
      (* Updated above. *)
      let updated = IUser.Assert.updated uid in
      Signals.on_update_call (updated , extract o) 
    | _             -> return ()

let set_password pass cuid = 

  let id = IUser.Deduce.is_anyone cuid in
  let update user = 
    let o = Data.({ user with passhash = Some (ConfigKey.passhash pass) }) in
    (), `put o
  in
  
  Tbl.transact id 
    (function 
      | None      -> return ((), `keep)
      | Some user -> return (update user))

let _get id = Tbl.get (IUser.decay id)

let get id = _get id |> Run.map (BatOption.map extract)

let knows_password pass id = 
  let! user = ohm_req_or (return None) $ _get id in
  if user.Data.confirmed && user.Data.passhash = Some (ConfigKey.passhash pass)
  then return $ Some (IUser.Assert.is_old id) 
  else return None

module Backdoor = struct

  module CountConfirmedView = CouchDB.ReduceView(struct
    module Key = Fmt.Unit
    module Value = Fmt.Int
    module Reduced = Fmt.Int
    module Design = Design
    let name   = "backdoor-count-confirmed"
    let map    = "if (doc.t == 'user' && doc.confirmed) emit(null,1);" 
    let group  = true 
    let level  = None 
    let reduce = "return sum(values);" 
  end)

  let count_confirmed = 
    CountConfirmedView.reduce_query () |> Run.map begin function
      | ( _, v ) :: _ -> v 
      | _ -> 0
    end

  module CountUndeletedView = CouchDB.ReduceView(struct
    module Key = Fmt.Unit
    module Value = Fmt.Int
    module Reduced = Fmt.Int
    module Design = Design
    let name   = "backdoor-count-undeleted"
    let map    = "if (doc.t == 'user' && !doc.destroyed) emit(null,1);" 
    let group  = true 
    let level  = None 
    let reduce = "return sum(values);"
  end)

  let count_undeleted =
    CountUndeletedView.reduce_query () |> Run.map begin function
      | ( _, v ) :: _ -> v 
      | _ -> 0
    end

  module DeletedView = CouchDB.MapView(struct
    module Key = Fmt.Unit
    module Value = Fmt.Make(struct
      type json t = <
	email     "e" : string ;
        time      "t" : float
      >
    end)
    module Design = Design
    let name = "backdoor-deleted"
    let map  = "if (doc.t == 'user' && doc.destroyed) emit(doc.destroyed,{
      e:doc.email,t:doc.destroyed});"
  end)

  let unsubscribed ~count = 
    let! list = ohm $ DeletedView.query ~limit:count ~descending:true () in
    return (List.map (#value) list) 

  let get _ uid = 
    get uid 

end

let obliterate uid =
  
  let  uid  = IUser.decay uid in
  let! user = ohm_req_or (return `missing) $ Tbl.get uid in 
  
  let! () = true_or (return `destroyed) (user.Data.destroyed = None) in

  let! () = ohm begin 
    match user.Data.picture with None -> return () | Some fid -> 
	(* Deletion acts as a bot - the user owns their picture. *)
      let fid = IFile.Assert.bot fid in
      MFile.delete_now fid
  end in
  
  let update user =
    Data.({
      user with 
	firstname = "" ;
	lastname  = "" ;
	passhash  = None ;
	email     = user.email ;
	emails    = List.filter snd user.emails ;
	facebook  = None ;
	confirmed = true ;
	destroyed = Some (Unix.gettimeofday ()) ;
	autologin = false ;
	picture   = None ;
	birthdate = None ;
	phone     = None ;
	cellphone = None ;
	address   = None ; 
	zipcode   = None ;
	city      = None ;
	country   = None ;
	gender    = None ;
	share     = [] ;
	blocktype = [] ;
	joindate  = 0.0 ;
    }) 
  in
  
  let! () = ohm $ Signals.on_obliterate_call uid in 
  let! () = ohm $ Tbl.update uid update in
  
  return `ok

let merge_unconfirmed ~merged ~into = 

  let merged_uid = IUser.decay merged in
  let into_uid   = IUser.decay into   in 

  (* Make sure the merged-into account exists *)
  let! _ = ohm_req_or (return ()) $ Tbl.get into_uid in

  (* Disable the merged account, retrieve the e-mail. *)
  let disable uid =     
    let! user = ohm_req_or (return (None, `keep)) $ Tbl.get uid in     
    if user.Data.confirmed then return (None, `keep) else
      return Data.(Some user.email, `put { user with email = "merged:<" ^ user.email ^ ">" ; emails = [] })
  in

  let! email = ohm_req_or (return ()) $ Tbl.Raw.transaction merged_uid disable in 
  let  email = EmailUtil.canonical email in 

  (* That account was confirmed, so add it to the list of valid e-mails of the merged-into account *)
  let add uid = 
    let! user = ohm_req_or (return ((), `keep)) $ Tbl.get uid in 
    return ((), `put Data.({
      user with emails = 
	(email, true) :: List.filter (fun (e,_) -> EmailUtil.canonical e <> email) user.emails 
    }))
  in

  let! () = ohm $ Tbl.Raw.transaction into_uid add in

  (* Propagate a merge signal and exit. *)
  let! () = ohm $ Signals.on_merge_call (merged_uid, into_uid) in

  return () 

let all_ids ~count start = Tbl.all_ids ~count start
