(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

module Core = struct

  let root,   def_root   = O.declare O.core "upload" A.none
  let cancel, def_cancel = O.declare O.core "upload/cancel" A.none
  let ok,     def_ok     = O.declare O.core "upload/confirm" (A.rr IOldFile.arg A.string) 
  let find,   def_find   = O.declare O.core "upload/find" A.none

end

module Client = struct

  let root,   def_root   = O.declare O.client "upload" A.none
  let cancel, def_cancel = O.declare O.client "upload/cancel" A.none
  let ok,     def_ok     = O.declare O.client "upload/confirm" (A.rr IOldFile.arg A.string) 
  let find,   def_find   = O.declare O.client "upload/find" A.none

  module Doc = struct
    let root, def_root = O.declare O.client "upload/file" (A.r IFolder.arg)
    let ok,   def_ok   = O.declare O.client "upload/file/confirm" (A.rr IOldFile.arg A.string)
  end

  module Img = struct
    let prepare, def_prepare = O.declare O.client "upload/img/prepare" (A.r IAlbum.arg)
    let confirm, def_confirm = O.declare O.client "upload/img/confirm" (A.rr IOldFile.arg A.string)
    let check,   def_check   = O.declare O.client "upload/img/check" (A.rr IOldFile.arg A.string)
  end

end
