(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

module Data    = MInstance_data
module Common  = MInstance_common
module Profile = MInstance_profile

include Common 

(* Registry ---------------------------------------------------------------------------- *)

module Registry = OhmCouchRegistry.Make(struct
  module Id = IInstance
  module Store = struct
    let host = "localhost"
    let port = 5984
    let database = O.db "instance-r"
  end
end)

(* Extraction -------------------------------------------------------------------------- *)

type t = <
  id      : IInstance.t ;
  key     : IWhite.key ;
  disk    : float ;
  seats   : int ;
  name    : string ;
  create  : float ;
  usr     : IUser.t ; 
  ver     : IVertical.t ;
  pic     : [`GetPic] IFile.id option ;
  plugins : IPlugin.t list ; 
> ;; 

let extract id i = Data.(object
  method id = IInstance.decay id 
  method key = i.key, i.white
  method name = i.name
  method disk = i.disk
  method create = i.create
  method seats = i.seats
  method usr = i.usr
  method ver = i.ver
  method pic = BatOption.map IFile.Assert.get_pic i.pic (* Can view instance *)
  method plugins = i.plugins
end)

(* Signals --------------------------------------------------------------------------------- *)
  
module Signals = struct

  let on_create_call, on_create = Sig.make (Run.list_iter identity) 
    
end

(* Various functions --------------------------------------------------------------------- *)

let create ~pic ~who ~key ~name ~address ~desc ~site ~contact ~vertical ~white = 

  let id = IInstance.gen () in

  let clip n s = if String.length s > n then String.sub s 0 n else s in 
  let now = Unix.gettimeofday () in
  let obj = Data.({
    t       = `Instance ;
    key     ;
    name    = clip 80 name ;
    disk    = 50.0 ;
    seats   = 30 ;
    create  = now ;
    usr     = IUser.Deduce.is_anyone who ;
    ver     = vertical ;
    pic     = BatOption.map IFile.decay pic ;
    white   ;
    plugins = [] ;
  }) in 

  let info old = Profile.Info.({ 
    old with     
      name     = clip 80 name ;
      key      ;
      white    ; 
      address  = BatOption.map (clip 300) address ;
      desc     ;
      site     = BatOption.map (clip 256) site ;
      contact  = BatOption.map (clip 256) contact ;
      pic      = BatOption.map IFile.decay pic ;
      unbound  = false ;
  }) in

  (* Log that we're creating this *)
  let! () = ohm $ MAdminLog.log ~uid:(IUser.Deduce.is_anyone who) ~iid:id MAdminLog.Payload.InstanceCreate in

  (* Created right here. *)
  let  cid = IInstance.Assert.created id in

  let!  () = ohm $ Profile.update id info in 
  let!  _  = ohm $ Tbl.set id obj in
  let!  () = ohm $ Signals.on_create_call cid in

  return cid

let update id ~name ~desc ~address ~site ~contact ~facebook ~twitter ~phone ~tags = 

  let id = IInstance.decay id in 
  let clip n s = if String.length s > n then String.sub s 0 n else s in
  let update ins = Data.({ 
    ins with name = clip 80 name ;
  }) in

  let! current = ohm_req_or (return ()) $ Tbl.get id in 

  let info old = Profile.Info.({    
    old with 
      name     = current.Data.name ;
      key      = current.Data.key ;
      white    = current.Data.white ; 
      address  = BatOption.map (clip 300)  address ;
      desc     ;
      site     = BatOption.map (clip 256)  site ;
      contact  = BatOption.map (clip 256)  contact ;
      facebook = BatOption.map (clip 256)  facebook ;
      twitter  = BatOption.map (clip 256)  twitter ;
      phone    = BatOption.map (clip 30)   phone ;
      tags     = BatList.sort_unique compare (List.map (Util.fold_all |- clip 32) tags) ;
      unbound  = false ;
  }) in

  let! () = ohm $ Profile.update id info in 
  Tbl.update (IInstance.decay id) update

let set_pic id pic = 
 
  let id  = IInstance.decay id in 
  let pic = BatOption.map IFile.decay pic in 

  let update ins = Data.({ ins with pic }) in
  let info   old = Profile.Info.({ old with pic }) in

  let! () = ohm $ Profile.update id info in 
  Tbl.update (IInstance.decay id) update

(* Plugins ----------------------------------------------------------------------------- *)

let has_plugin t plugin = 
  List.mem plugin (t # plugins) 

(* Fetch by key ------------------------------------------------------------------------ *)
    
module ViewByKey = CouchDB.DocView(struct
  module Key    = Fmt.Make(struct type json t = (string * IWhite.t option) end)
  module Value  = Fmt.Unit
  module Doc    = Data
  module Design = Design
  let name = "by_key"
  let map =  "if (doc.t == 'inst') emit([doc.key,doc.white],null)"
end)

let by_key_cache = Hashtbl.create 100

let by_key_real key = 
  let! list = ohm $ ViewByKey.doc key in
  match list with [] -> return None | first :: _ ->
    let iid = IInstance.of_id (first # id) in 
    return $ Some iid
      
let by_key ?(fresh=false)key =
  if fresh then by_key_real key else
    try return (Some (Hashtbl.find by_key_cache key))
    with Not_found -> let! iid = ohm_req_or (return None) $ by_key_real key in
		      let () = Hashtbl.add by_key_cache key iid in
		      return $ Some iid 
			
let get iid = 
  Tbl.using (IInstance.decay iid) (extract iid)
  
let get_free_space id = 
  get id |> Run.map begin function 
    | Some ins -> ins # disk
    | None     -> 0.0
  end

let free_name (name,owid) =
  
  let name = IInstanceKey.clean name in

  let rec aux i name = 

    if i = 100 then raise Not_found else
      
      let full_name = name ^ (if i = 1 then "" else "-"^string_of_int i) in
      
      let! forbidden = ohm begin
	if IInstanceKey.forbidden full_name then return true else
	  by_key (full_name,owid) |> Run.map BatOption.is_some
      end in
      
      if forbidden then aux (i+1) name else return full_name 
  in

  aux 1 name

(* Recent visits ---------------------------------------------------------------- *)

module Recent = Fmt.Make(struct
  type json t = <
    t : MType.t ;
    i : IInstance.t list 
  > ;; 
end) 

module RecentTable = CouchDB.Table(MyDB)(Id)(Recent)

module FindRecent = Fmt.Make(struct
  type json t = (Id.t * int)
end) 

let visited ~count user = 

  let id = ICurrentUser.to_id user in 
  let! recent = ohm_req_or (return []) $ RecentTable.get id in

  return (BatList.take count (recent # i)) 

let visit user inst = 

  let id = ICurrentUser.to_id user in
 
  let add_recent inst = function

    | None -> let obj = object
                method t = `LastVisit
                method i = [ inst ]
              end in
	      (), `put obj

    | Some x -> let l = inst :: (BatList.remove (x # i) inst) in		      
		if l = x # i then (), `keep else
		  let obj = object 
		    method t = `LastVisit
		    method i = l		     
		  end in
		  (), `put obj
  in

  RecentTable.transact id (add_recent inst |- return)

(* Installing instances ------------------------------------------------------------- *)

let install iid ~pic ~who ~key ~name ~desc = 

  let iid = IInstance.decay iid in 

  let! profile = ohm_req_or (return None) $ Profile.get iid in 
  let! () = true_or (return (Some (profile # key))) (profile # unbound <> None) in
  
  let name = BatString.strip name in 
  let name = if name = "" then profile # name else name in 

  let owid = snd (profile # key) in
  
  let! key = ohm $ free_name (key,owid) in 

  let clip n s = if String.length s > n then String.sub s 0 n else s in 
  let now = Unix.gettimeofday () in

  let obj = Data.({
    t       = `Instance ;
    key     ;
    name    = clip 80 name ;
    disk    = 50.0 ;
    seats   = 30 ;
    create  = now ;
    usr     = IUser.Deduce.is_anyone who ;
    ver     = ConfigWhite.default_vertical owid ;
    pic     = BatOption.map IFile.decay pic ;
    white   = owid ;
    plugins = [] ;
  }) in 

  let info old = Profile.Info.({ 
    old with     
      name     = clip 80 name ;
      pic      = BatOption.map IFile.decay pic ;
      key      ;
      desc     ;
      unbound  = false ;
  }) in

  (* Log that we're creating this *)
  let! () = ohm $ MAdminLog.log ~uid:(IUser.Deduce.is_anyone who) ~iid MAdminLog.Payload.InstanceCreate in

  (* Created right here. *)
  let  cid = IInstance.Assert.created iid in

  let!  () = ohm $ Profile.update iid info in 
  let!  _  = ohm $ Tbl.set iid obj in
  let!  () = ohm $ Signals.on_create_call cid in

  return (Some (key,owid))

(* The backdoor --------------------------------------------------------------------- *)

module Backdoor = struct

  module CountView = CouchDB.ReduceView(struct
    module Key = Fmt.Unit
    module Value = Fmt.Int
    module Reduced = Fmt.Int
    module Design = Design
    let name   = "backdoor-count"
    let map    = "if (doc.t == 'inst') emit(null,1);"
    let reduce = "return sum(values);"
    let group  = true
    let level  = None
  end)

  let count : int O.run =
    let! data = ohm $ CountView.reduce_query () in
    return (match data with 
      | ( _, v ) :: _ -> v 
      | _ -> 0)

  let relocate ~src ~dest = 
    let! iid = ohm_req_or (return `NOT_FOUND) $ by_key ~fresh:true src in
    let! collision = ohm $ by_key ~fresh:true dest in
    if collision <> None then
      if collision = Some iid then return `OK else return `EXISTS
    else
      let key, white = dest in 
      let! _ = ohm $ Tbl.update iid (fun ins -> Data.({ ins with key ; white })) in 
      let! _ = ohm $ Profile.update iid (fun old -> Profile.Info.({ old with key ; white })) in
      return `OK

  let list ~count start = 
    let! ids, next = ohm $ Tbl.all_ids ~count start in
    let! insts = ohm $ Run.list_filter begin fun iid ->
      let! inst = ohm_req_or (return None) $ get iid in 
      return (Some (iid, inst))
    end ids in

    return (insts, next)

  let set_plugins plugins src = 
    let! iid = ohm_req_or (return `NOT_FOUND) $ by_key ~fresh:true src in
    let! _ = ohm $ Tbl.update iid (fun ins -> Data.({ ins with plugins })) in
    return `OK 

end

