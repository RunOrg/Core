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
  let! log = ohm_req_or (return None) (Tbl.get h.Handle.id) in
  return log.Data.author 

let upload store author ~public ~filename local = 
  
  let! time = ohmctx (#time) in
  let! provider = req_or (return None) (Store.provider store) in

  let! size = req_or (return None) begin 
    try let chan = Pervasives.open_in_bin local in
	try let size = Pervasives.in_channel_length chan in
	    Pervasives.close_in chan ; Some (float_of_int size /. 1024.) 
	with _ -> Pervasives.close_in chan ; None
    with _ -> None
  end in 

  let! fileT = ohm_req_or (return None) (provider # upload ~public ~filename local) in

  let store, storeT = store in 
  
  let data = Data.({
    owner  = Some (provider # owner) ;
    author = Some author ;
    name   = filename ;
    size   ;
    store  ;
    storeT ;
    fileT  ;
    del    = None ;
    time   ;
    delok = false ;
  }) in

  let! id = ohm (Tbl.create data) in
  
  return (Some Handle.({ id ; store ; storeT ; fileT }))

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
