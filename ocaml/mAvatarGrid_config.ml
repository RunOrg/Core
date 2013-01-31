(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Key = IAvatar
  
module Source = Fmt.Make(struct
  type json t = 
    [ `Avatars  of IInstance.t
    | `Profiles of IInstance.t
    | `Group    of IAvatarSet.t
    ]
end)
  
module Evaluator = MAvatarGridEval 
module Column    = MAvatarGridColumn 
  
let evaluator_of_column t = t.Column.eval

module ListDB = CouchDB.Convenience.Config(struct let db = O.db "avatar-grid" end)
module LineDB = CouchDB.Convenience.Config(struct let db = O.db "avatar-grid-l" end)
module UniqDB = CouchDB.Convenience.Config(struct let db = O.db "avatar-grid-u" end)
  
let background operation = 
  O.async # periodic 10 (let! continue = ohm operation in return (if continue then None else Some 2.0)) 
  
let sources_of_evaluator = function 
  | `Avatar  (iid,_) -> [`Avatars  iid]
  | `Profile (iid,_) -> [`Profiles iid]
  | `Group   (gid,_) -> [`Group    gid]
    
let apply_avatar aid what = 
  let! d = ohm $ MAvatar.details aid in
  let! picture = ohm begin 
    match d # picture with 
      | None     -> return None 
      | Some fid -> MFile.Url.get fid `Small
  end in
  return begin match what with 
    | `Name -> begin 
      Json.of_opt Json.of_string (d # name),
      BatOption.map Json.of_string (d # sort)
    end 
  end

type ctx = O.ctx
let context ctx = (ctx :> CouchDB.ctx) 

let apply_profile aid what = 
  let empty = Json.Null, None in
  let! pid = ohm $ MAvatar.profile aid in 
  (* We can view the profile to read columns from it. *)
  let  pid = IProfile.Assert.view pid in 
  let! _, profile = ohm_req_or (return empty) $ MProfile.data pid in
  let retstring s = return (Json.String s, Some (Json.String (Util.fold_all s))) in
  let retoptstr = function None -> return empty | Some s -> retstring s in
  let gender    = function 
    | Some `m -> return (Json.String "m", None)
    | Some `f -> return (Json.String "f", None)
    | None    -> return empty
  in
  MProfile.Data.(match what with 
    | `Firstname -> retstring profile.firstname
    | `Lastname  -> retstring profile.lastname
    | `Email     -> retoptstr profile.email
    | `Birthdate -> return (Json.of_opt Date.to_json profile.birthdate, None)
    | `Phone     -> retoptstr profile.phone
    | `Cellphone -> retoptstr profile.cellphone 
    | `Address   -> retoptstr profile.address
    | `Zipcode   -> retoptstr profile.zipcode 
    | `Country   -> retoptstr profile.country 
    | `City      -> retoptstr profile.city
    | `Gender    -> gender    profile.gender 
    | `Full      -> begin 

      let collected = MAvatar.collect_profile profile in 
      let sort = Some begin match collected # sort with 
	| [] -> Json.Null 
	| h :: _ -> Json.String h 
      end in 

      let! pic = ohm $ Run.opt_bind (fun fid -> MFile.Url.get fid `Small) profile.picture in

      let data = (object
	method fullname = collected # name
	method email    = profile.email
	method gender   = profile.gender
	method picture  = pic 
      end) in

      return (MAvatarGridEval.FullProfile.to_json data, sort) 

    end

  )
    
let apply_group_core mid what = 
  let! data = ohm $ MMembership.get mid in 
  match what with 
    | `Status -> let stat_opt = BatOption.map (fun d -> d.MMembership.status) data in 
		 let stat = BatOption.default `NotMember stat_opt in
		 return $ MMembership.Status.to_json stat
    | `InList -> let stat_opt = BatOption.map (fun d -> d.MMembership.status) data in 
		 let stat = BatOption.default `NotMember stat_opt in
		 return $ Json.Bool (stat <> `NotMember)
    | `Date   -> let date_opt = BatOption.map (fun d -> d.MMembership.time) data in 
		 return $ Json.of_opt Fmt.Float.to_json date_opt
		   
let apply_group_data mid name = 
  let! data = ohm $ MMembership.Data.get mid in 
  let  item = ListAssoc.try_get data name in 
  return $ BatOption.default Json.Null item 
    
let apply_group aid gid what = 
  (* We can view any memberships. *)
  let  gid = IAvatarSet.Assert.bot gid in
  let! exists = ohm $ MAvatar.exists aid in 
  if not exists then return Json.Null else 
    let! mid = ohm $ MMembership.as_admin gid aid in  
    match what with 
      | `Status  -> apply_group_core mid `Status
      | `Date    -> apply_group_core mid `Date
      | `InList  -> apply_group_core mid `InList
      | `Field n -> apply_group_data mid n 
      
let apply aid what = 
  match what with 
    | `Avatar  ( _ ,what) -> apply_avatar  aid what
    | `Profile ( _ ,what) -> apply_profile aid what
    | `Group   (gid,what) -> let! json = ohm $ apply_group   aid gid what in
			     return (json, None)  
    
let all_lines source ~from ~count =
  match source with 
    | `Avatars _ | `Profiles _ -> return ([],None)
    | `Group gid -> 
      (* We can view any memberships *)
      let gid = IAvatarSet.Assert.bot gid in 
      MMembership.InSet.avatars gid ~start:from ~count
  
