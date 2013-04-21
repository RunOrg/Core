(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal

module Mailer = MMail.Register(struct

  include Fmt.Make(struct
    type json t = <
      uid  : IUser.t ;
      list : (IInstance.t * (IInboxLineOwner.t * float * [`Wall|`Folder|`Album] * int) list) list
    >
  end)

  let id = IMail.Plugin.of_string "digest"

  let iid t = 
    match t # list with 
    | [ iid, _ ] -> Some iid
    | _ -> None

  let uid t = t # uid

  let from  _ = None
  let solve _ = None
  let item  _ = false

end)

type t = Mailer.t
let define f = Mailer.define f 

let max_age = 3600. *. 24. *. 7. (* A week *)

let get_last now map iid =
  try BatPMap.find iid map with Not_found -> now -. max_age

let send uid sent = 
  
  let! now = ohmctx (#time) in
  let  get_last = get_last now sent in 

  (* Building digest : need to see instances.  *)
  let  self = IUser.Assert.is_self uid in 
  let! actors = ohm (MAvatar.user_avatars self) in
  
  (* Retrieve digest for each instance *) 
  let! byiid = ohm (Run.list_filter begin fun actor -> 
    let  iid   = IInstance.decay (MActor.instance actor) in 
    let  since = get_last iid in 
    let! list  = ohm (MInboxLine.View.digest ~since ~count:10 actor begin fun t ->
      let! what, count = req_or (return None) begin 
	match t # wall # unread with Some n -> Some (`Wall,n) | None -> 
	  match t # folder # unread with Some n -> Some (`Folder,n) | None -> 
	    match t # album # unread with Some n -> Some (`Album,n) | None -> None
      end in
      return (Some (t # owner, t # time, what, count))
    end) in
    if list = [] then return None else return (Some (iid, list)) 
  end actors) in

  (* If there's nothing to be send, just give up. *)
  if byiid = [] then return sent else
    
    (* Create digest e-mail. *)
    let! () = ohm (Mailer.send_one (object
      method uid  = uid 
      method list = byiid
    end)) in  
    
    (* Update "last sent" for all instances. *)  
    return (List.fold_left (fun map (iid,_) -> BatPMap.add iid now map) sent byiid) 

