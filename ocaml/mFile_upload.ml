(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Ops         = MFile_ops
module Store       = MFile_store
module UploadToken = MFile_uploadToken
module Handle      = MFile_handle

(* General type definitions *)

type info = <
  handle   : Handle.t ;
  filename : string ; 
  size     : float ;  
  local    : string
>

type form = string -> < post : (string * string) list ; key : string ; url : string >

module type POSTUPLOADER = sig
  include Ohm.Fmt.FMT
  val id : IFile.PostUploader.t
  val author : t -> (#O.ctx,[`Avatar of IAvatar.t | `User of IUser.t] option) Ohm.Run.t
  val process : t -> info -> (#O.ctx,unit) Ohm.Run.t
end

(* The database of pending uploads *)

module Data = struct
  module T = struct
    type json t = {
      store   : Store.t ;
      handle  : Json.t ; 
      uploadT : Json.t ;
      upload  : IFile.PostUploader.t ;
      expires : float ; 
    }
  end
  include T
  include Fmt.Extend(T)
end

include CouchDB.Convenience.Table(struct let db = O.db "file-pending" end)(Id)(Data)

(* Confirming uploads (delayed, because it might take a while) *) 

let uploaders = Hashtbl.create 10 

let task_confirm = O.async # define "file-confirm-upload" Id.fmt begin fun id ->
  
  let! file = ohm_req_or (return ()) (Tbl.get id) in
  
  let! provider = req_or (return ()) (Store.provider file.Data.store) in
  let! fileT = ohm_req_or (return ()) (provider # find file.Data.handle) in
  let! info = ohm_req_or (return ()) (provider # download fileT) in

  let  store, storeT = file.Data.store in 
  let  handle = Handle.({ id ; store ; storeT ; fileT }) in

  let! author = ohm begin 
    try O.decay ((Hashtbl.find uploaders file.Data.upload) # author file.Data.uploadT)
    with Not_found -> return None 
  end in

  let! () = ohm (Ops.register handle author (info # size) (info # filename)) in
  let! () = ohm (Tbl.delete id) in

  if author = None then return () else 

    let info = object
      method handle   = handle
      method filename = info # filename
      method size     = info # size
      method local    = info # local
    end in 
    
    try O.decay ((Hashtbl.find uploaders file.Data.upload) # process file.Data.uploadT info)
    with Not_found -> return () 

end

let confirm id = 
  O.decay (task_confirm id)
    
(* Uploader functor that creates pending uploads. *)

module Uploader = functor(P:POSTUPLOADER) -> struct

  type t = P.t

  let () = Hashtbl.add uploaders P.id (object
    method process json info = 
      let! t = req_or (return ()) (P.of_json_safe json) in
      P.process t info 
    method author json = 
      let! t = req_or (return None) (P.of_json_safe json) in
      P.author t
  end)
    
  let prepare ?(maxsize=10.0) store t = 

    let! provider = req_or (return None) (Store.provider store) in
    let! prep     = ohm_req_or (return None) (provider # prepare ~maxsize) in
    let  handle   = prep # handle in
    let  uploadT  = P.to_json t in

    let! now  = ohmctx (#time) in 
    let  data = Data.({ store ; handle ; upload = P.id ; uploadT ; expires = now +. 3600. }) in

    let! id = ohm (Tbl.create data) in
    
    return (Some (id, prep # form))

end

(* TODO : cleanup dead pending uploads... *)
