(* © 2012 MRunOrg *)

open Ohm
open Ohm.Universal

module Details = MMembership_details

include Fmt.Make(struct
  type json t = 
    [ `Invite  "i" of < who "a" : IAvatar.t >
    | `Admin   "a" of < who "a" : IAvatar.t ; what "w" : bool >
    | `User    "u" of < who "a" : IAvatar.t ; what "w" : bool >
    | `Payment "p" of < who "a" : IAvatar.t ; paid "w" : bool >  
    ]
end)

let apply = function
  | `Invite  i -> return (fun _ t d -> return (Details.invite t (i#who) d))
  | `Admin   a -> return (fun _ t d -> return (Details.admin_decision (a#who) t (a#what) d))
  | `User    u -> return (fun _ t d -> return (Details.user_decision (u#who) t (u#what) d))
  | `Payment p -> return (fun _ t d -> return (Details.payment (p#who) t (p#paid) d))
    
let admin who what = `Admin (object
  method who  = IAvatar.decay who
  method what = what
end)

let user who what = `User (object
  method who  = IAvatar.decay who 
  method what = what
end)

let invite who = `Invite (object
  method who = IAvatar.decay who
end)

let relevant_change data = function
  | `Admin  a -> begin match data.Details.admin with 
      | None -> true
      | Some (old,_,_) -> old <> a # what 
  end
  | `Invite i -> true
  | `User   u -> begin match data.Details.user with 
      | None -> true
      | Some (old,_,who) ->
	if who = data.Details.who then who = u # who && old <> u # what else
	  who = data.Details.who || old <> u # what
  end
  | `Payment p -> false
