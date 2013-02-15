(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Get = DMS_MDocument_get

(* Store a "pending" note in a side database. The pending note contains 
   all information to create whatever should be created post-upload. 
   Key for the note is the IFile.t being uploaded. *)

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

include CouchDB.Convenience.Table(struct let db = O.db "dms-doc-upload" end)(IFile)(Pending)

(* These functions are available from outside this module and are
   used to create the "pending" notes. They should return the fresh 
   IFile.t *)

let create ~self ~iid rid = 

  O.decay begin

    let! fid = ohm_req_or (return None) $ MFile.Upload.prepare_doc
      ~ins:iid
      ~usr:(IUser.Deduce.is_anyone (MActor.user self))
      ()
    in 
    
    let iid = IInstance.decay iid in
    let rid = DMS_IRepository.decay rid in 
    let aid = IAvatar.decay (MActor.avatar self) in 

    let pending = wrap (NewDoc.make ~rid ~iid ~aid) in 
 
    let! _ = ohm $ Tbl.set (IFile.decay fid) pending in
    return (Some fid) 

  end

let add_version ~self ~iid t = 

  O.decay begin

    let! fid = ohm_req_or (return None) $ MFile.Upload.prepare_doc
      ~ins:iid
      ~usr:(IUser.Deduce.is_anyone (MActor.user self))
      ()
    in 
    
    let did = DMS_IDocument.decay (Get.id t) in 
    let aid = IAvatar.decay (MActor.avatar self) in 

    let pending = wrap (NewVersion.make ~did ~aid) in 
 
    let! _ = ohm $ Tbl.set (IFile.decay fid) pending in
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
  let! pending = ohm_req_or (return None) $ Tbl.get (IFile.decay fid) in
  return (ok pending) 
