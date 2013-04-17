(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Handle = MFile_handle
module UploadToken = MFile_uploadToken
module Store = MFile_store
module Upload = MFile_upload
module Ops = MFile_ops

(* Export internal types and modules *) 

type store = Store.store
module type STORAGE = Store.STORAGE
module RegisterStorage = Store.RegisterStorage

type form = Upload.form
type upload_info = Upload.info
module type POSTUPLOADER = Upload.POSTUPLOADER
module Uploader = Upload.Uploader

(* Define remaining types and functions *)

type local_path = string

let confirm id = 
  Upload.confirm id 

let store h = 
  (h.Handle.store, h.Handle.storeT)

let delete h = 
  Ops.delete h 

let uploader h = 
  Ops.uploader h

let upload store uploader ?(public=false) ~filename path = 
  Ops.upload store uploader ~public ~filename path 

let url h = 
  Handle.url h

let download h = 
  Handle.download h 
