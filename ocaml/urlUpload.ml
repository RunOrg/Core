(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

module Core = struct

  let root,   def_root   = O.declare O.core "upload" A.none
  let cancel, def_cancel = O.declare O.core "upload/cancel" A.none
  let ok,     def_ok     = O.declare O.core "upload/success" (A.r IFile.arg) 

end
