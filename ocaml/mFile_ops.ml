(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Handle = MFile_handle
module Store = MFile_store

module Data = struct
  module T = struct
    type json t = {
      owner  : [`User "u" of IUser.t | `Instance "i" of IInstance.t] option ;
      author : [`User "u" of IUser.t | `Avatar "a" of IAvatar.t] option ; 
      name   : string ;
      size   : float ; 
      store  : IFile.Storage.t ;
      storeT : Ohm.Json.t ;
      fileT  : Ohm.Json.t ; 
      del    : float option ;
      time   : float ; 
      delok  : bool ; 
    }
  end
  include T
  include Fmt.Extend(T)
end

include CouchDB.Convenience.Table(struct let db = O.db "file-log" end)(Id)(Data)

let delete h = 
  let! time = ohmctx (#time) in
  Tbl.update h.Handle.id 
    (fun d -> Data.({ d with del = Some (BatOption.default time (BatOption.map (min time) d.del)) })) 

let uploader h = 
  return None

let upload store author ~public ~filename local = 
  return None

let register h author ~size ~filename = 

  let! time = ohmctx (#time) in

  let owner =  
    let! provider = req_or None (Handle.provider h) in
    Some (provider # owner)
  in

  let data = Data.({
    owner ;
    author ;
    name = filename ;
    size ;
    store = h.Handle.store ;
    storeT = h.Handle.storeT ;
    fileT = h.Handle.fileT ;
    del = (if author = None || owner = None then Some time else None) ;
    time ;
    delok = false ;
  }) in

  Tbl.set h.Handle.id data
