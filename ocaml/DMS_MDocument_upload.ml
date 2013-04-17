(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Get = DMS_MDocument_get
module Set = DMS_MDocument_set
module E   = DMS_MDocument_core

(* Store a "pending" note in a side database. The pending note contains 
   all information to create whatever should be created post-upload. 
   Key for the note is the IOldFile.t being uploaded. *)

module NewDoc = struct
  module T = struct
    type json t = {
      ok  : bool ;
      did : DMS_IDocument.t ; 
      rid : DMS_IRepository.t ;
      iid : IInstance.t ;
      aid : IAvatar.t ;
    }
  end
  include T
  include Fmt.Extend(T)
  let make ~rid ~iid ~aid = `Doc { 
    ok  = false ;
    did = DMS_IDocument.gen () ;
    rid ;
    iid ;
    aid
  }
end

module NewVersion = struct
  module T = struct
    type json t = {
      ok  : bool ;
      did : DMS_IDocument.t ;
      aid : IAvatar.t ;
    }
  end
  include T
  include Fmt.Extend(T)
  let make ~did ~aid = `Version {
    ok  = false ;
    did ;
    aid
  }
end

module Pending = Fmt.Make(struct
  type json t = <
    what : [ `Doc "d" of NewDoc.t | `Version "v" of NewVersion.t ]
  >
end)

let wrap what = object
  method what = what
end

include CouchDB.Convenience.Table(struct let db = O.db "dms-doc-upload" end)(IOldFile)(Pending)

(* These functions are available from outside this module and are
   used to create the "pending" notes. They should return the fresh 
   IOldFile.t *)

let create ~self ~iid rid = 

  O.decay begin

    let! fid = ohm_req_or (return None) $ MOldFile.Upload.prepare_doc
      ~ins:iid
      ~usr:(IUser.Deduce.is_anyone (MActor.user self))
      ()
    in 
    
    let iid = IInstance.decay iid in
    let rid = DMS_IRepository.decay rid in 
    let aid = IAvatar.decay (MActor.avatar self) in 

    let pending = wrap (NewDoc.make ~rid ~iid ~aid) in 
 
    let! _ = ohm $ Tbl.set (IOldFile.decay fid) pending in
    return (Some fid) 

  end

let add_version ~self ~iid t = 

  O.decay begin

    let! fid = ohm_req_or (return None) $ MOldFile.Upload.prepare_doc
      ~ins:iid
      ~usr:(IUser.Deduce.is_anyone (MActor.user self))
      ()
    in 
    
    let did = DMS_IDocument.decay (Get.id t) in 
    let aid = IAvatar.decay (MActor.avatar self) in 

    let pending = wrap (NewVersion.make ~did ~aid) in 
 
    let! _ = ohm $ Tbl.set (IOldFile.decay fid) pending in
    return (Some fid) 

  end

(* Keep track of whether an upload is finished, and return the
   corresponding document when it is. *)

let ok pending = 
  let ok, did = match pending # what with 
    | `Doc     d -> NewDoc.(d.ok,d.did)
    | `Version v -> NewVersion.(v.ok,v.did)
  in
  if ok then Some did else None

let ready fid = 
  let! pending = ohm_req_or (return None) $ Tbl.get (IOldFile.decay fid) in
  let! did     = req_or (return None) $ ok pending in
  let! found   = ohm $ MOldFile.check fid `File in
  return (if found then Some did else None)

(* React to an upload being completed successfully. *)

let finish_doc name ext size fid doc = 

  let! time = ohmctx (#time) in
  let  aid  = doc.NewDoc.aid in
  let! self = ohm_req_or (return ()) $ MAvatar.actor (IAvatar.Assert.is_self aid) in 
  let  init = E.({
    iid     = doc.NewDoc.iid ;
    name    ;
    repos   = [ doc.NewDoc.rid ] ;
    version = (object
      method number   = 1 
      method filename = name
      method size     = size
      method ext      = ext
      method file     = fid 
      method time     = time
      method author   = aid 
    end) ;
    creator = aid ;
    last    = (time, aid) ;
  }) in
  
  let! () = ohm $ E.create doc.NewDoc.did self init [] in
  Tbl.set fid (object method what = `Doc NewDoc.({ doc with ok = true }) end)
	
let finish_version name ext size fid version = 

  let! time = ohmctx (#time) in
  let  aid  = version.NewVersion.aid in
  let  did  = version.NewVersion.did in 
  let! self = ohm_req_or (return ()) $ MAvatar.actor (IAvatar.Assert.is_self aid) in 
  let  diff = [ `AddVersion (object
      method number   = 1 
      method filename = name
      method size     = size
      method ext      = ext
      method file     = fid 
      method time     = time
      method author   = aid 
  end) ] in

  let! () = ohm $ Set.raw diff did self in
  Tbl.set fid (object method what = `Version NewVersion.({ version with ok = true }) end)
  
let () = 
  let! _, name, ext, size, fid = Sig.listen MOldFile.Upload.Signals.on_item_doc_upload in
  let! pending = ohm_req_or (return ()) $ Tbl.get fid in 
  match pending # what with 
    | `Doc     d -> finish_doc name ext size fid d
    | `Version v -> finish_version name ext size fid v 
