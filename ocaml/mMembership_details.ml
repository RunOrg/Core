(* © 2013 RunOrg *)

open Ohm
    
module T = struct

  type json t = {
    where   : IAvatarSet.t  ;
    who     : IAvatar.t ;
    admin   : (bool * float * IAvatar.t) option ; 
    user    : (bool * float * IAvatar.t) option ;
    invited : (bool * float * IAvatar.t) option ;
    paid    : (bool * float * IAvatar.t) option 
  }

  type data = t = {
    where   : IAvatarSet.t  ;
    who     : IAvatar.t ;
    admin   : (bool * float * IAvatar.t) option ; 
    user    : (bool * float * IAvatar.t) option ;
    invited : (bool * float * IAvatar.t) option ;
    paid    : (bool * float * IAvatar.t) option 
  }

end 
include T
include Fmt.Extend(T)

let default group avatar = {
  where   = IAvatarSet.decay  group ;
  who     = IAvatar.decay avatar ;
  admin   = None ;
  user    = None ;
  invited = None ;
  paid    = None ;
}
  
let invite time who t = 
  { t with invited = Some (true, time, who) }
    
let admin_decision admin time decision t = 
  { t with admin = Some (decision, time, admin) }
    
let user_decision user time decision t = 
  match t.user with 
    (* Someone other than the user is not allowed to override the
       user's decision. *)
    | Some (_,_,user') when user' = t.who && user <> t.who -> t
    | _ -> { t with user = Some (decision, time, user) }
    
let payment user time paid t = 
  { t with paid = Some (paid, time, user) } 
    
let last t = 
  List.fold_left max 0.0
    (BatList.filter_map (BatOption.map (fun (_,t,_) -> t))
       [ t.admin ; t.user ; t.invited ; t.paid ])
    
let status ~manual t = 

  let admin_denied time = 
    match t.user with 
      | Some (true, time',who) when time < time' && who = t.who -> `Pending
      | Some (false,time',who) when time < time' && who = t.who -> `Declined
      | _ -> match t.invited with
	  | Some (true,time',_) when time < time' -> `Invited
	  | _                                     -> `NotMember
  in

  let admin_missing () = 

    let user_missing () = 
      match t.invited with 
	| Some (true,_,_) -> `Invited
	| _               -> `NotMember
    in

    let user_answered decision who =
      if who <> t.who then `Invited else
	if decision then `Pending else 
	  match t.invited with 
	    | Some (true,_,_) -> `Declined
	    | _               -> `NotMember
    in
    
    match t.user with 
      | None                  -> user_missing ()
      | Some (decision,_,who) -> user_answered decision who

  in

  let admin_accepted () = 

    let user_missing () = 
      match t.invited with 
	| Some (true,_,_) -> `Invited
	| _               -> `NotMember
    in

    let user_refused () = 
      match t.invited with 
	| Some (true,_,_) -> `Declined
	| _               -> `NotMember
    in
    
    match t.user with 
      | Some (true,_,_)    -> `Member
      | None               -> user_missing () 
      | Some (false,_,who) -> if who = t.who then user_refused () else `Invited

  in

  match t.admin with 
    | Some (false,time,_) -> admin_denied time
    | Some (true,_,_)     -> admin_accepted ()
    | None                -> if manual then admin_missing () else admin_accepted () 


