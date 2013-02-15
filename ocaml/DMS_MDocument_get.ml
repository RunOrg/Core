(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module E    = DMS_MDocument_core
module Can  = DMS_MDocument_can

type version = <
  number   : int ; 
  filename : string ; 
  size     : float ; 
  ext      : MFile.Extension.t ;
  file     : [`GetDoc] IFile.id ; 
  time     : float ;
  author   : IAvatar.t ;
> ;;

let publish v = object
  method number = v # number
  method filename = v # filename
  method size     = v # size
  method ext      = v # ext
  method file     = IFile.Assert.get_doc (v # file) 
  method time     = v # time
  method author   = v # author
end

(* Primary properties *)

let id t = Can.id t
let name t = (Can.data t).E.name
let iid t = (Can.data t).E.iid
let repositories t = (Can.data t).E.repos
let current t = publish (Can.data t).E.version
let version t = (current t) # number 
let last_update t = (Can.data t).E.last 
