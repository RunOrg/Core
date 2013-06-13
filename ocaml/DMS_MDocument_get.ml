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
  file     : [`GetDoc] IFile.id option ; 
  time     : float ;
  author   : IAvatar.t ;
> ;;

let publish allow v = object
  method number = v # number
  method filename = v # filename
  method size     = v # size
  method ext      = v # ext
  method file     = if allow then Some (IFile.Assert.get_doc (v # file)) else None
  method time     = v # time
  method author   = v # author
end

(* Primary properties *)

let id t = Can.id t
let name t = (Can.data t).E.name
let iid t = (Can.data t).E.iid
let repositories t = (Can.data t).E.repos
let version t = (Can.data t).E.version # number 
let last_update t = (Can.data t).E.last 

let current t = 
  let! download = ohm (Can.download t) in
  return (publish download (Can.data t).E.version)

let current_info t = 
  publish false (Can.data t).E.version
