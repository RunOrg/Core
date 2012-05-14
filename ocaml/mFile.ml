(* © 2012 Runorg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

module MyTable = MFile_common.MyTable

module Upload    = MFile_upload
module Url       = MFile_url
module Usage     = MFile_usage
module Extension = MFile_extension 

type version = MFile_common.version

let own_pic usr id = 
  MyTable.get (IFile.decay id) |> Run.map (BatOption.bind begin fun file ->
    if file # usr = IUser.decay usr && file # ins = None && file # k = `Picture then 
      Some (IFile.Assert.own_pic id)
    else None
  end)

let instance_pic ins id = 
  MyTable.get (IFile.decay id) |> Run.map (BatOption.bind begin fun file ->  
    if file # ins = Some ins && file # k = `Picture then 
      Some (IFile.Assert.ins_pic id)
    else None
  end)

let set_facebook_pic pic user details = 

  let id = IFile.decay pic in 
  let obj = object
    method t        = `File
    method k        = `Extern
    method usr      = IUser.decay user
    method ins      = None
    method key      = Id.of_string "-"
    method item     = None
    method name     = Some "profile.jpg"
    method versions = [
      MFile_common.small, (object
	method size = 0.0
	method name = details # pic_small
      end) ;
      MFile_common.large, (object
	method size = 0.0
	method name = details # pic_large
      end)
    ]
  end in
  
  MyTable.transaction id (MyTable.insert obj) |> Run.map ignore

let give_pic pic ins = 

  let id = IFile.decay pic in   
  let give file = 
    if file # ins <> None then (), `keep else
      (), `put (object
	method t        = `File
	method k        = file # k
	method usr      = file # usr
	method ins      = Some (IInstance.decay ins) 
	method key      = file # key
	method versions = file # versions
	method item     = file # item 
	method name     = file # name
      end)
  in

  MyTable.transaction id (MyTable.if_exists give) |> Run.map ignore
     		   
(* When instance is created, give the pic. *) 

let _ = 
  let act iid =
    let  iid = IInstance.decay iid in
    let! instance = ohm_req_or (return ()) $ MInstance.get iid in
    match instance # pic with 
      | None     -> return ()
      | Some pid -> give_pic pid iid
  in
  Sig.listen MInstance.Signals.on_create act

(* Delete a file now *)

let delete_now fid = 

  let fid = IFile.decay fid in
  let versions = [ `Original ; `File ; `Small ; `Large ] in

  let remove version = 
    let! success = ohm $ MFile_upload.remove ~version fid in 
    match success with
      | Some false -> Run.of_lazy (lazy (raise Async.Reschedule))
      | _          -> return ()
  in

  let! ()  = ohm $ Run.list_iter remove versions in

  return () 

let item fid = 
  let   fid = IFile.decay fid in 
  let! file = ohm_req_or (return None) $ MyTable.get fid in
  return (file # item) 
