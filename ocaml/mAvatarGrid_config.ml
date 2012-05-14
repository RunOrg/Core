(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Key = IAvatar
  
module Source = Fmt.Make(struct
  type json t = 
    [ `Avatars  of IInstance.t
    | `Profiles of IInstance.t
    | `Group    of IGroup.t
    ]
end)
  
module Evaluator = MAvatarGrid_eval 
module Column    = MAvatarGrid_column 
  
let evaluator_of_column t = t.Column.eval

module ListDB = CouchDB.Convenience.Config(struct let db = O.db "avatar-grid" end)
module LineDB = CouchDB.Convenience.Config(struct let db = O.db "avatar-grid-l" end)
module UniqDB = CouchDB.Convenience.Config(struct let db = O.db "avatar-grid-u" end)
  
let background operation = Task.Background.register 10 operation 
  
let sources_of_evaluator = function 
  | `Avatar  (iid,_) -> [`Avatars  iid]
  | `Profile (iid,_) -> [`Profiles iid]
  | `Group   (gid,_) -> [`Group    gid]
    
let apply_avatar aid what = 
  let! d = ohm $ MAvatar.details aid in
  return begin match what with 
    | `Name -> begin 
      BatOption.(default Json_type.Null $ map Json_type.Build.string (d # name)),
      BatOption.map Json_type.Build.string (d # sort)
    end 
  end
 

let apply_profile aid what = 
  let empty = Json_type.Null, None in
  let! pid = ohm $ MAvatar.profile aid in 
  (* We can view the profile to read columns from it. *)
  let  pid = IProfile.Assert.view pid in 
  let! _, profile = ohm_req_or (return empty) $ MProfile.data pid in
  let retstring s = Json_type.String s, Some (Json_type.String (Util.fold_all s)) in
  let retoptstr = function None -> empty | Some s -> retstring s in
  let gender    = function 
    | Some `m -> Json_type.String "m", None
    | Some `f -> Json_type.String "f", None
    | None    -> empty
  in
  return MProfile.Data.(match what with 
    | `Firstname -> retstring profile.firstname
    | `Lastname  -> retstring profile.lastname
    | `Email     -> retoptstr profile.email
    | `Birthdate -> retoptstr profile.birthdate
    | `Phone     -> retoptstr profile.phone
    | `Cellphone -> retoptstr profile.cellphone 
    | `Address   -> retoptstr profile.address
    | `Zipcode   -> retoptstr profile.zipcode 
    | `Country   -> retoptstr profile.country 
    | `City      -> retoptstr profile.city
    | `Gender    -> gender    profile.gender 
  )
    
let apply_group_core mid what = 
  let! data = ohm $ MMembership.get mid in 
  match what with 
    | `Status -> let stat_opt = BatOption.map (fun d -> d.MMembership.status) data in 
		 let stat = BatOption.default `NotMember stat_opt in
		 return $ MMembership.Status.to_json stat
    | `InList -> let stat_opt = BatOption.map (fun d -> d.MMembership.status) data in 
		 let stat = BatOption.default `NotMember stat_opt in
		 return $ Json_type.Bool (stat <> `NotMember)
    | `Date   -> let date_opt = BatOption.map (fun d -> d.MMembership.time) data in 
		 return $ Json_type.Build.optional Fmt.Float.to_json date_opt
		   
let apply_group_data mid name = 
  let! data = ohm $ MMembership.Data.get mid in 
  let  item = ListAssoc.try_get data name in 
  return $ BatOption.default Json_type.Null item 
    
let apply_group aid gid what = 
  (* We can view any memberships. *)
  let  gid = IGroup.Assert.bot gid in
  let! exists = ohm $ MAvatar.exists aid in 
  if not exists then return Json_type.Null else 
    let! mid = ohm $ MMembership.as_admin gid aid in  
    match what with 
      | `Status  -> apply_group_core mid `Status
      | `Date    -> apply_group_core mid `Date
      | `InList  -> apply_group_core mid `InList
      | `Field n -> apply_group_data mid n 
      
let apply aid what = 
  Run.edit_context CouchDB.ctx_decay begin match what with 
    | `Avatar  ( _ ,what) -> apply_avatar  aid what
    | `Profile ( _ ,what) -> apply_profile aid what
    | `Group   (gid,what) -> let! json = ohm $ apply_group   aid gid what in
			     return (json, None)
  end
    
let all_lines source ~from ~count = 
  Run.edit_context CouchDB.ctx_decay begin match source with 
    | `Avatars _ | `Profiles _ -> return ([],None)
    | `Group gid -> 
      (* We can view any memberships *)
      let gid = IGroup.Assert.bot gid in 
      MMembership.InGroup.avatars gid ~start:from ~count
  end
