(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Diff      = MMembership_diff
module Versioned = MMembership_versioned

(* Mass application of an admin operation ------------------------------------------------------------------- *)

let admin_one gid diffs aid = 
  let! _ = ohm $ Versioned.apply gid aid diffs in
  return ()

module AdminFmt = Fmt.Make(struct
  type json t = (IInstance.t * Diff.t list * MAccess.t * IAvatar.t option * IAvatarSet.t)
end)

let admin_slice = 10
let admin_task, define_admin_task = 
  O.async # declare "membership-mass-admin" AdminFmt.fmt 

let () = define_admin_task begin fun (iid,diffs,access,start,gid) -> 
  let  biid = IInstance.Assert.bot iid in 
  let! aids, next = ohm $ MReverseAccess.reverse biid ?start ~count:admin_slice [access] in 
  let! () = ohm $ Run.list_iter (admin_one gid diffs) aids in
  if next <> None then 
    admin_task (iid,diffs,access,next,gid) 
  else
    return () 
end 

let admin_task iid gid access diffs =
  match access with 
    | `Nobody -> return ()
    | `List [aid] -> admin_one gid diffs aid
    | _   -> admin_task (iid,diffs,access,None,gid) 
    
let admin ~from iid gid access what = 
  let gid   = IAvatarSet.decay gid in 
  let iid   = IInstance.decay iid in 
  let diffs = List.map (Diff.make from) what in
  if diffs = [] then return () else 
    (* Start the insertion task *)
    admin_task iid gid access diffs
	
(* Creating avatars and adding them to a group -------------------------------------------------------------- *)

let create_one (email,firstname,lastname) iid gid diffs = 

  let general = MProfile.Data.({
    firstname ;
    lastname ;
    email     = Some email ;
    birthdate = None ;
    phone     = None ;
    cellphone = None ;
    address   = None ;
    zipcode   = None ;
    city      = None ;
    country   = None ;
    picture   = None ;
    gender    = None ;
  }) in 
  
  let! result = ohm $ MProfile.create iid general in

  let user = match result with `ok (user,_) | `exists user -> user in
  
  let! aid = ohm $ MAvatar.become_contact iid user in

  admin_one gid diffs aid 

module CreateArgs = Fmt.Make(struct
  type json t = < 
    iid    : IInstance.t ; 
    input  : (string * string * string) list ;
    gid    : IAvatarSet.t ;
    diffs  : Diff.t list 
  > 
end)

let create_step = 10
let create_task, define_create_task = O.async # declare "invite-create" CreateArgs.fmt

let create_task input iid gid diffs = 
  match input with 
    | [] -> return () 
    | [one] -> create_one one iid gid diffs
    | list -> create_task (object
      method iid = iid
      method input = list
      method gid = gid
      method diffs = diffs
    end)

let () = define_create_task begin fun args -> 
 
  let make what = create_one what (args # iid) (args # gid) (args # diffs) in 
  let list, rest = try BatList.split_at create_step args # input with _ -> args # input, [] in
      
  let! () = ohm $ Run.list_iter make list in 

  create_task rest (args # iid) (args # gid) (args # diffs)

end

let create ~from iid gid list what = 
  if list = [] then return () else
    let iid   = IInstance.decay iid in     
    let gid   = IAvatarSet.decay gid in 
    let diffs = List.map (Diff.make from) what in
    if diffs = [] then return () else 

      (* Log that we're doing this. *)
      let! () = ohm begin 
	let  uid = IUser.Deduce.is_anyone (MActor.user from) in
	let  iid = IInstance.decay (MActor.instance from) in
	let! g   = ohm_req_or (return ()) $ MAvatarSet.naked_get gid in 
	let  own = MAvatarSet.Get.owner g in
	let  p   = `Create in 
	MAdminLog.log ~uid ~iid (MAdminLog.Payload.MembershipMass (p,own,List.length list))
      end in 

      (* Run the actual task *)
      create_task list iid gid diffs
